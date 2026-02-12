local Utils = {}

function Utils.get_current_buffer()
    local buffer = vim.api.nvim_buf_get_name(0)
    vim.notify("Buffer " .. buffer)
end

return Utils
