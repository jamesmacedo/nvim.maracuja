local config = require("maracuja.config")

local movement = {}

function movement.jump_to(mark_id)
    local m = config.state.marks[mark_id]
    if m ~= nil then

        if not vim.api.nvim_buf_is_valid(m.buf) then
            vim.notify("Buffer is no longer valid")
            return
        end

        local pos = vim.api.nvim_buf_get_extmark_by_id(m.buf, config.tracker, m.pos_id, {})
        if next(pos) ~= nil then
            vim.api.nvim_win_set_buf(m.win, m.buf)
            vim.api.nvim_win_set_cursor(m.win, { pos[1] + 1, pos[2] })
        end
    end
end

return movement
