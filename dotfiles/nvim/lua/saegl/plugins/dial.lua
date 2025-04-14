return {
    {
        'monaqa/dial.nvim',
        config = function()
            vim.keymap.set("n", "<leader>=", function()
                require("dial.map").manipulate("increment", "normal")
            end, { desc = 'increment' })
            vim.keymap.set("n", "<leader>-", function()
                require("dial.map").manipulate("decrement", "normal")
            end, { desc = 'decrement' })
            vim.keymap.set("n", "g<C-a>", function()
                require("dial.map").manipulate("increment", "gnormal")
            end)
            vim.keymap.set("n", "g<C-x>", function()
                require("dial.map").manipulate("decrement", "gnormal")
            end)
            vim.keymap.set("v", "<leader>=", function()
                require("dial.map").manipulate("increment", "visual")
            end)
            vim.keymap.set("v", "<leader>-", function()
                require("dial.map").manipulate("decrement", "visual")
            end)
            vim.keymap.set("v", "g<C-a>", function()
                require("dial.map").manipulate("increment", "gvisual")
            end)
            vim.keymap.set("v", "g<C-x>", function()
                require("dial.map").manipulate("decrement", "gvisual")
            end)

            local augend = require("dial.augend")
            require("dial.config").augends:register_group {
                default = {
                    augend.integer.alias.decimal,
                    augend.integer.alias.hex,
                    augend.date.alias["%Y/%m/%d"],
                    augend.date.new {
                        pattern = "%A",
                        default_kind = "day",
                        only_valid = true,
                        word = true,
                    },
                    augend.constant.new {
                        elements = { "and", "or" },
                        word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
                        cyclic = true, -- "or" is incremented into "and".
                    },
                    augend.constant.new {
                        elements = { "false", "true" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "False", "True" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "off", "on" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "Off", "On" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "no", "yes" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "No", "Yes" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = {
                            "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
                            "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho",
                            "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega"
                        },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = {
                            "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta",
                            "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho",
                            "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega"
                        },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = {
                            "α", "β", "γ", "δ", "ε", "ζ", "η", "θ",
                            "ι", "κ", "λ", "μ", "ν", "ξ", "ο", "π",
                            "ρ", "σ", "τ", "υ", "φ", "χ", "ψ", "ω"
                        },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = {
                            "Α", "Β", "Γ", "Δ", "Ε", "Ζ", "Η", "Θ",
                            "Ι", "Κ", "Λ", "Μ", "Ν", "Ξ", "Ο", "Π",
                            "Ρ", "Σ", "Τ", "Υ", "Φ", "Χ", "Ψ", "Ω"
                        },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = {
                            "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
                            "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
                        },
                        word = false,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = {
                            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
                            "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
                        },
                        word = false,
                        cyclic = true,
                    },
                }
            }
        end
    }
}
