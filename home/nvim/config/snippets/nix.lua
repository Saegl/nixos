local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local extras = require 'luasnip.extras'
local rep = extras.rep
local fmt = require('luasnip.extras.fmt').fmt


return {
    s("toggle_mod", fmt(
        [[
        {{
          lib,
          config,
          ...
        }}: {{
          options = {{
            {}.enable = lib.mkEnableOption "enable {}";
          }};
          config = lib.mkIf config.{}.enable {{
            {}
          }};
        }}
        ]], { i(1), rep(1), rep(1), i(2) }
    )),
    s("toggle_option", fmt(
        [[
        options = {{
          nixld.enable = lib.mkEnableOption "enable nixld";
        }};
        config = lib.mkIf config.nixld.enable {{
          {}
        }}
        ]], { i(1) }
    )),
}
