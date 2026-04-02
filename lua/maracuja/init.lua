local commands = require("maracuja.logic.commands")
local config = require("maracuja.config")
local mark = require("maracuja.models.mark")

vim.opt.signcolumn = "yes:2"

local M = {}

M.setup = function() end

local SALTO_UMBRAL = 20 

-- vim.api.nvim_create_autocmd({"CursorMoved", "BufEnter"}, {
--     group = vim.api.nvim_create_augroup("MonitorMov", { clear = true }),
--     callback = function()
--         local current_line = vim.fn.line('.')
--         local current_buf = vim.api.nvim_get_current_buf()
--         local current_win = vim.api.nvim_get_current_win()
--         local current_pos = vim.api.nvim_win_get_cursor(0)
--
--         local last = config.state.leap_history_buffer[1]
--
--         if current_buf ~= last.buffer then
--             local l = {
--                 buffer = current_buf,
--                 line = current_line,
--                 win = current_win,
--                 pos = current_pos,
--             }
--
--             table.insert(config.state.leap_history_buffer, 1, l)
--
--             if #config.state.leap_history_buffer > 4 then
--                 table.remove(config.state.leap_history_buffer)
--             end
--             return
--         end
--
--         local diff = math.abs(current_line - last.line)
--
--         if diff > SALTO_UMBRAL then
--             table.insert(config.state.leap_history, 1, mark.new(last.buffer, last.win, last.pos))
--         end
--     end,
-- })

vim.keymap.set("n", "s", ":MarkShow<CR>", { noremap = true, silent = true, nowait = true })
vim.keymap.set("n", "<leader>ss", ":MarkToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>sa", ":MarkRewind<CR>", { noremap = true, silent = true })

commands()

return M
