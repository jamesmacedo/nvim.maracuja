local commands = require("maracuja.logic.commands")
local state = require("maracuja.models.state")

vim.opt.signcolumn = "yes:2"

local M = {}

M.setup = function() end

state.setup()

vim.keymap.set("n", "<leader>]", ":MarkCircle<CR>", { noremap = true, silent = true, nowait = true })
vim.keymap.set("n", "<leader>]]", ":MarkToggle<CR>", { noremap = true, silent = true })

commands()

return M
