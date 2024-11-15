local ls = require 'luasnip'

local s = ls.snippet
local i = ls.insert_node
local extras = require 'luasnip.extras'
local rep = extras.rep
local fmt = require('luasnip.extras.fmt').fmt


return {
    -- so meta
    s("snippet", fmt(
        [=[
        local ls = require 'luasnip'
        local s = ls.snippet
        local i = ls.insert_node
        local extras = require 'luasnip.extras'
        local rep = extras.rep
        local fmt = require('luasnip.extras.fmt').fmt

        return {{
            s("{}", fmt(
                [[
                print("Hey this is me {{}}, by {{}}")
                ]], {{ i(0), rep(0) }}
            )),
        }}
        ]=], { i(0) }
    )),
}
