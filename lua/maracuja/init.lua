local commands = require("maracuja.logic.commands")

vim.opt.signcolumn = "yes:2"

local M = {}

M.setup = function() end

vim.keymap.set("n", "s", ":MarkShow<CR>", { noremap = true, silent = true, nowait = true })
vim.keymap.set("n", "<leader>ss", ":MarkToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>sa", ":MarkRewind<CR>", { noremap = true, silent = true })

commands()

return M
