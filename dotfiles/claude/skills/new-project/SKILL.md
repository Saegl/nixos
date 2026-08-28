---
name: new-project
description: Scaffold a new project from scratch - interview, name suggestions, dependency picks, then uv/cargo/vite setup with direnv, a Justfile, and dev tooling wired up. Use when the user wants to start, create, bootstrap, or scaffold a new project, repo, service, or app.
---

# New Project

Interview, propose, then scaffold. Create nothing on disk until name, stack, path, and dependencies are confirmed.

## 1. Interview

Skip anything the invocation already answers. Batch the rest into one AskUserQuestion:

- **Name** — suggest 4. Short, lowercase, memorable over descriptive; no `-app`, `-tool`, `py-` filler. Check the target path is free before offering it.
- **Stack** — python+uv | vite+typescript | rust. Infer a default from the description: API, script, game → python; browser UI → vite; CLI, systems, perf → rust.
- **Path** — `~/projects/python`, `~/projects/rust`, `~/projects/js`, or `~/projects/<name>/` for a multirepo holding several services.

## 2. Dependencies

Propose a list and wait. Usual picks: fastapi + uvicorn (HTTP), httpx (client), pyglet (graphics, games). Dev group is always mypy, ruff, pytest.

Flag anything shipping native libs — it decides step 4.

## 3. Scaffold

### Python

```bash
uv init --app --no-package <name>   # flat layout: no src/, no build-system
cd <name> && mkdir -p <package> tests && touch <package>/__init__.py
uv add <deps>; uv add --dev mypy ruff pytest
```

`uv init` slugifies to dashes; the package dir needs underscores. Add to `pyproject.toml`:

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["."]
addopts = "-q"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "UP", "B", "SIM", "C4", "RUF"]

[tool.mypy]
files = ["<package>", "tests"]
check_untyped_defs = true
disallow_untyped_defs = true
```

`.envrc` — `uv sync` first so `.venv` exists, then `direnv allow`:

```bash
dotenv_if_exists
source .venv/bin/activate
```

### Rust

`cargo new <name>`. `.envrc` is `dotenv_if_exists` alone — no venv line.

### Vite + TypeScript

`pnpm create vite <name> --template vanilla-ts` (or `react-ts`), then `pnpm install`.

## 4. System libs (NixOS)

Wheels with native deps (pyglet, opencv, torch) fail here. Escalate in order:

1. **Project-scoped** — `shell.nix` plus `use nix` at the top of `.envrc`:
   ```nix
   {pkgs ? import <nixpkgs> {}}:
   pkgs.mkShell {
     buildInputs = [pkgs.mesa pkgs.libGL];
   }
   ```
2. **Already system-wide** — nix-ld serves it; one line in `.envrc` is enough:
   `export LD_LIBRARY_PATH="$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH"`
3. **Wanted by many projects** — propose a diff to `~/projects/nix/nixos/frostmourne.nix`: `programs.nix-ld.libraries` for runtime `.so`, `environment.systemPackages` for CLI tools, applied with `just sw`. Never edit that file without an explicit yes.

## 5. Justfile

Root `Justfile`, recipes named for what the user will actually type. Python:

```just
default:
    @just --list

run:
    uv run python -m <package>

all: && lint test
    uv run ruff format

lint:
    uv run ruff check
    uv run mypy

test:
    uv run pytest
```

Rust swaps in `cargo run` / `cargo fmt` / `cargo clippy -- -D warnings` / `cargo test`; vite uses `pnpm dev`, `pnpm build`, `pnpm exec tsc --noEmit`.

## 6. Finish

1. `direnv allow`, then `just all`. The scaffold passes its own checks before you hand it over.
2. Secrets? Write `.env.example` and gitignore `.env`.
3. README: one line on what it is, plus the recipes.
4. Leave the first commit to the user unless asked.
