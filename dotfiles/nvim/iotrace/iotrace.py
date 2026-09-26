"""Pytest plugin: record inputs/outputs and executed lines of project functions for lua/iotrace.lua.

Usage: PYTHONPATH=~/.config/nvim/iotrace pytest -p iotrace [args]
Env:   IOTRACE_PATHS  comma-separated dirs to trace, relative to rootdir (default: app)
       IOTRACE_MAX    calls kept per function (default: 20)
       IOTRACE_REPR   max repr length (default: 5000)
       IOTRACE_WIDTH  pretty-print width (default: 80)
Output: <rootdir>/.pytest_cache/iotrace.json
"""

from __future__ import annotations

import ast
import dataclasses
import dis
import inspect
import json
import linecache
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from types import CodeType

mon = sys.monitoring
E = mon.events
TOOL_ID = mon.PROFILER_ID

MAX_CALLS = int(os.environ.get("IOTRACE_MAX", 20))
MAX_REPR = int(os.environ.get("IOTRACE_REPR", 5000))
WIDTH = int(os.environ.get("IOTRACE_WIDTH", 80))
MAX_YIELDS = 10
GEN_FLAGS = inspect.CO_GENERATOR | inspect.CO_ASYNC_GENERATOR
SCOPE_NODES = (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)


MAX_ITEMS = 50


def _fields(value: object) -> list[tuple[str, object]] | None:
    """Fields of pydantic models and dataclasses, read without triggering custom __getattr__."""
    cls = type(value)
    pydantic_fields = getattr(cls, "__pydantic_fields__", None)
    if isinstance(pydantic_fields, dict):
        attrs = getattr(value, "__dict__", {})
        return [(n, attrs[n]) for n, f in pydantic_fields.items() if n in attrs and getattr(f, "repr", True)]
    if dataclasses.is_dataclass(cls) and cls.__dataclass_params__.repr:
        return [(f.name, getattr(value, f.name)) for f in dataclasses.fields(cls) if f.repr]
    return None


def _pretty(value: object, indent: int = 0, prefix: int = 0, depth: int = 0) -> str:
    """Black-style multi-line repr; `prefix` is the width of what precedes the value on its first line."""
    text = repr(value)
    if indent + prefix + len(text) <= WIDTH or depth > 6:
        return text
    inner = indent + 4
    cls = type(value)
    if cls is dict:
        pairs = list(value.items())[:MAX_ITEMS]
        items = [f"{k!r}: {_pretty(v, inner, len(repr(k)) + 2, depth + 1)}" for k, v in pairs]
        opening, closing = "{", "}"
    elif cls in (list, tuple, set, frozenset):
        items = [_pretty(v, inner, 0, depth + 1) for v in list(value)[:MAX_ITEMS]]
        opening, closing = {list: "[]", tuple: "()", set: "{}", frozenset: ("frozenset({", "})")}[cls]
    elif (fields := _fields(value)) is not None:
        items = [f"{n}={_pretty(v, inner, len(n) + 1, depth + 1)}" for n, v in fields[:MAX_ITEMS]]
        opening, closing = f"{cls.__name__}(", ")"
    else:
        return text
    total = len(value) if cls in (dict, list, tuple, set, frozenset) else len(fields)
    if total > MAX_ITEMS:
        items.append(f"... ({total - MAX_ITEMS} more)")
    lines = []
    if cls in (list, tuple, set, frozenset) and all("\n" not in item for item in items):
        # Pack short sequence items onto shared lines
        for item in items:
            if lines and inner + len(lines[-1]) + len(item) + 2 <= WIDTH:
                lines[-1] += f" {item},"
            else:
                lines.append(f"{item},")
    else:
        lines = [f"{item}," for item in items]
    pad = " " * inner
    return opening + "\n" + "".join(f"{pad}{line}\n" for line in lines) + " " * indent + closing


def _repr(value: object) -> str:
    try:
        text = _pretty(value)
    except Exception as e:
        text = f"<repr failed: {e!r}>"
    return text if len(text) <= MAX_REPR else text[:MAX_REPR] + " …"


def _start(node: ast.AST) -> int:
    if isinstance(node, ast.match_case):
        return node.pattern.lineno
    decorators = getattr(node, "decorator_list", None)
    return decorators[0].lineno if decorators else node.lineno


def _end(node: ast.AST) -> int:
    return node.body[-1].end_lineno if isinstance(node, ast.match_case) else node.end_lineno


def _children(node: ast.AST) -> list[ast.AST]:
    kids = [
        n
        for n in ast.iter_child_nodes(node)
        if isinstance(n, (ast.stmt, ast.ExceptHandler, ast.match_case))
    ]
    return sorted(kids, key=_start)


def _owners(stmts: list[ast.AST], owner: dict[int, int]) -> None:
    """Map every line of `stmts` to the first line of the statement whose execution it depends on."""
    for s in stmts:
        kids = [] if isinstance(s, SCOPE_NODES) else _children(s)
        start = _start(s)
        if not kids:
            for line in range(start, _end(s) + 1):
                owner[line] = start
            continue
        for line in range(start, _start(kids[0])):
            owner[line] = start
        _owners(kids, owner)
        # Lines between blocks (`else:`, `finally:`, comments) run only if the next block does
        for prev, nxt in zip(kids, kids[1:]):
            for line in range(_end(prev) + 1, _start(nxt)):
                owner[line] = _start(nxt)


@dataclass
class CodeInfo:
    key: str
    stores: dict[int, list[str]]  # line -> local names assigned on it
    owner: dict[int, int] = field(default_factory=dict)
    fireable: set[int] = field(default_factory=set)  # owners that emit LINE events


class Tracer:
    def __init__(self, root: Path, paths: list[str]) -> None:
        self.root = root
        self.prefixes = tuple(str(root / p) + os.sep for p in paths)
        self.current_test: str | None = None
        # [relpath, 1-based line] of the current test function
        self.current_test_loc: list | None = None
        # "relpath:firstlineno" -> {"name", "file", "line", "def_line", "source", "calls": [...]}
        self.functions: dict[str, dict] = {}
        self.infos: dict[CodeType, CodeInfo | None] = {}
        self.trees: dict[str, ast.Module | None] = {}
        # id(frame) -> call record; frames of suspended coroutines stay alive, so ids are stable
        self.pending: dict[int, dict] = {}

    def _tree(self, filename: str) -> ast.Module | None:
        if filename not in self.trees:
            try:
                self.trees[filename] = ast.parse("".join(linecache.getlines(filename)))
            except SyntaxError:
                self.trees[filename] = None
        return self.trees[filename]

    def _info(self, code: CodeType) -> CodeInfo | None:
        if code in self.infos:
            return self.infos[code]
        info = None
        if code.co_filename.startswith(self.prefixes) and not code.co_name.startswith("<"):
            rel = os.path.relpath(code.co_filename, self.root)
            info = CodeInfo(key=f"{rel}:{code.co_firstlineno}", stores={})
            for ins in dis.get_instructions(code):
                if ins.opname in ("STORE_FAST", "STORE_DEREF") and ins.positions.lineno:
                    names = info.stores.setdefault(ins.positions.lineno, [])
                    if ins.argval not in names:
                        names.append(ins.argval)
            fn = {"name": code.co_qualname, "file": rel, "line": code.co_firstlineno, "calls": []}
            node = self._node(code)
            if node is not None:
                _owners(node.body, info.owner)
                executable = {line for *_, line in code.co_lines() if line}
                info.fireable = {o for line, o in info.owner.items() if line in executable}
                lines = linecache.getlines(code.co_filename)[code.co_firstlineno - 1 : node.end_lineno]
                fn |= {"def_line": node.lineno, "source": "".join(lines)}
            self.functions[info.key] = fn
            mon.set_local_events(TOOL_ID, code, E.LINE)
        self.infos[code] = info
        return info

    def _node(self, code: CodeType) -> ast.AST | None:
        tree = self._tree(code.co_filename)
        for node in ast.walk(tree) if tree else ():
            if (
                isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
                and node.name == code.co_name
                and _start(node) == code.co_firstlineno
            ):
                return node
        return None

    def _line(self, call: dict, line: int) -> dict:
        return call["lines"].setdefault(line, {})

    def _flush(self, call: dict, info: CodeInfo, frame) -> None:
        """Record values assigned by the line that just finished."""
        line = call["_prev"]
        names = info.stores.get(line)
        if names:
            f_locals = frame.f_locals
            vals = self._line(call, line).setdefault("vals", {})
            for name in names:
                if name in f_locals:
                    vals[name] = _repr(f_locals[name])

    def _finish(self, code: CodeType, frame, kind: str, value: object) -> None:
        call = self.pending.pop(id(frame), None)
        if call is None:
            return
        info = self.infos[code]
        call[kind] = _repr(value)
        if call["_prev"] is not None:
            self._flush(call, info, frame)
            self._line(call, call["_prev"])[kind] = call[kind]
        hit = {info.owner.get(line) for line in call["lines"] if call["lines"][line].get("hits")}
        call["dead"] = [line for line, o in info.owner.items() if o in info.fireable and o not in hit]
        del call["_prev"]

    def on_start(self, code: CodeType, _offset: int):
        info = self._info(code)
        if info is None:
            return mon.DISABLE
        calls = self.functions[info.key]["calls"]
        if len(calls) >= MAX_CALLS:
            mon.set_local_events(TOOL_ID, code, 0)
            return mon.DISABLE
        frame = sys._getframe(1)
        nargs = code.co_argcount + code.co_kwonlyargcount
        nargs += bool(code.co_flags & inspect.CO_VARARGS) + bool(code.co_flags & inspect.CO_VARKEYWORDS)
        f_locals = frame.f_locals
        call = {
            "test": self.current_test,
            "test_loc": self.current_test_loc,
            "args": [[name, _repr(f_locals[name])] for name in code.co_varnames[:nargs] if name in f_locals],
            "lines": {},
            "_prev": None,
        }
        calls.append(call)
        self.pending[id(frame)] = call

    def on_line(self, code: CodeType, line: int):
        frame = sys._getframe(1)
        call = self.pending.get(id(frame))
        if call is None:
            return
        if call["_prev"] is not None:
            self._flush(call, self.infos[code], frame)
        entry = self._line(call, line)
        entry["hits"] = entry.get("hits", 0) + 1
        call["_prev"] = line

    def on_return(self, code: CodeType, _offset: int, retval: object):
        if self.infos.get(code) is None:
            return mon.DISABLE
        self._finish(code, sys._getframe(1), "return", retval)

    def on_unwind(self, code: CodeType, _offset: int, exc: BaseException):
        if self.infos.get(code) is not None:
            self._finish(code, sys._getframe(1), "raise", exc)

    def on_yield(self, code: CodeType, _offset: int, value: object):
        # Awaits in coroutines also fire PY_YIELD; only generators yield real output
        if self.infos.get(code) is None or not code.co_flags & GEN_FLAGS:
            return mon.DISABLE
        call = self.pending.get(id(sys._getframe(1)))
        if call is not None and call["_prev"] is not None:
            yields = self._line(call, call["_prev"]).setdefault("yields", [])
            if len(yields) < MAX_YIELDS:
                yields.append(_repr(value))

    def start(self) -> None:
        mon.use_tool_id(TOOL_ID, "iotrace")
        mon.register_callback(TOOL_ID, E.PY_START, self.on_start)
        mon.register_callback(TOOL_ID, E.LINE, self.on_line)
        mon.register_callback(TOOL_ID, E.PY_RETURN, self.on_return)
        mon.register_callback(TOOL_ID, E.PY_UNWIND, self.on_unwind)
        mon.register_callback(TOOL_ID, E.PY_YIELD, self.on_yield)
        # LINE is enabled per traced code object in _info
        mon.set_events(TOOL_ID, E.PY_START | E.PY_RETURN | E.PY_UNWIND | E.PY_YIELD)

    def stop(self) -> None:
        mon.set_events(TOOL_ID, 0)
        for code, info in self.infos.items():
            if info is not None:
                mon.set_local_events(TOOL_ID, code, 0)
        mon.free_tool_id(TOOL_ID)

    def dump(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        for call in self.pending.values():
            call.pop("_prev", None)
        data = {k: v for k, v in self.functions.items() if v["calls"]}
        for fn in data.values():
            for call in fn["calls"]:
                for entry in call["lines"].values():
                    if "vals" in entry:
                        entry["vals"] = list(entry["vals"].items())
        path.write_text(json.dumps(data, ensure_ascii=False))


_tracer: Tracer | None = None


def _human_size(size: float) -> str:
    for unit in ("B", "K", "M"):
        if size < 1024:
            return f"{size:.1f}{unit}"
        size /= 1024
    return f"{size:.1f}G"


def pytest_configure(config) -> None:
    global _tracer
    paths = os.environ.get("IOTRACE_PATHS", "app").split(",")
    _tracer = Tracer(Path(config.rootpath), paths)
    _tracer.start()


def pytest_runtest_protocol(item, nextitem) -> None:
    _tracer.current_test = item.nodeid
    path, lineno, _ = item.location
    _tracer.current_test_loc = [path, lineno + 1 if lineno is not None else 1]


def pytest_unconfigure(config) -> None:
    _tracer.stop()
    out = Path(config.rootpath) / ".pytest_cache" / "iotrace.json"
    _tracer.dump(out)
    calls = sum(len(f["calls"]) for f in _tracer.functions.values())
    print(f"\niotrace: {calls} calls -> {out} ({_human_size(out.stat().st_size)})")
