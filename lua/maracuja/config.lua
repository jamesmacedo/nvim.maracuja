local MAX_HISTORY = 2

local M = {}

M.state = {
    position = 1,
    history = {},
    marks = {},
    orders = {},
    is_menu_open = false
}

function M.add_history(mark)
    table.insert(M.state.history, 1, mark)

    if #M.state.history > MAX_HISTORY then
        table.remove(M.state.history)
    end
end


M.buffer = vim.api.nvim_create_buf(false, true)
M.colors = {
    stale = "#ff00ff",
    active = "#ffffff"
}
M.tracker = vim.api.nvim_create_namespace("mark_tracker")
M.ui = vim.api.nvim_create_namespace("ui")

return M
