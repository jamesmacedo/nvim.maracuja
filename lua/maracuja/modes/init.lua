local M = {}

local _current_mode = "normal"

M.modes = {
    normal = require("maracuja.modes.normal"),
    -- temporal = require("maracuja.modes.temporal")
}

function M.get_mode()

    local is_avalable = false
    local mode = M.modes[_current_mode]
    local _, height = mode:get_lines()

    if height > 0 then
       is_avalable = true
    end

    return mode, is_avalable
end

function M.set_mode(mode)
    if M.modes[mode] ~= nil then
        _current_mode = mode
        return M.modes[mode]
    else
        vim.print("Mode not found")
    end
end

function M.circle()
    next = false
    for key, _ in pairs(M.modes) do

        if next then
            _current_mode = key
        end

        if key == _current_mode then
            next = true
        end
    end
end


return M
