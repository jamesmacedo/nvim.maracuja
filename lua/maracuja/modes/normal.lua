local uc = require("maracuja.ui.config")

local config = require("maracuja.config")
local mark = require("maracuja.models.mark")
local helpers = require("maracuja.helpers")
local fun = require("maracuja.vendor.fun")
local serpent = require("maracuja.vendor.serpent")

local M = {}

M.marks = {}
M.history = {}

function M:add_mark()

	local buffer = vim.api.nvim_get_current_buf();
	local win = vim.api.nvim_get_current_win()
	local pos = vim.api.nvim_win_get_cursor(0)

	local raw_line = vim.api.nvim_buf_get_lines(buffer, pos[1] - 1, pos[1] + 1, false)[1]
	local line = vim.trim(raw_line)

	local ids = {}
	for _, ma in pairs(self.marks) do
		table.insert(ids, ma.id)
	end

	local id = nil

	local i = 1
	for char in line:gmatch(".") do
		if helpers.tabl.has_value(ids, char) == false then
			id = line:sub(i, i)
			break
		end
		i = i + 1
	end

	-- The code commented out below belongs to a previous version, i'm retaining it here for future reference 
	--
	-- local keys_iter = fun.map(function(k, _) return k end, self.orders)
	-- local sorted_keys = fun.totable(keys_iter)
	--
	-- table.sort(sorted_keys)
	--
	-- local new_arr = {}
	--
	-- fun.each(function(k)
	-- 	new_arr[k] = self.orders[k]
	-- end, sorted_keys)

	if id ~= nil then
		local m = mark.new(id, pos, buffer, win)
		self.marks[id] = m
	else
		vim.notify("nil id")
	end
end

function M:get_lines()

    local lines = {}
	local last = nil

	if #self.history > 1 then
		last = self.history[2]
	end

	if last then
		table.insert(lines, { content = " " .. last.line:sub(0, uc.MAX_COL_ROWS) .. " ", id = last.id })
	end

	for _, m in pairs(self.marks) do
		if last and last.id == m.id then
			goto continue
		end

		table.insert(
			lines,
			{ content = " " .. m.line:sub(0, uc.MAX_COL_ROWS), id = m.id }
		)

	    ::continue::
	end

    return lines, helpers.tablelength(lines)
end

function M:on_select(id)
	-- TODO: Create a validation system to delete the mark if it doesn't exist anymore
	self:jump_to(id)
end

function M:switch()
	vim.notify("length: " .. #self.history)

	if #self.history > 1 then
		vim.notify("Id: " .. self.history[1].id)
		self:jump_to(self.history[1].id)
	else
		vim.notify("Not enough marks")
	end

end

function M:jump_to(mark_id)

    local m = self.marks[mark_id]
    if m ~= nil then

        if not vim.api.nvim_buf_is_valid(m.buffer) then
            vim.notify("Buffer is no longer valid")
            return
        end

        local pos = vim.api.nvim_buf_get_extmark_by_id(m.buffer, config.tracker, m.pos_id, {})
        if next(pos) ~= nil then
            vim.api.nvim_win_set_buf(m.win, m.buffer)
            vim.api.nvim_win_set_cursor(m.win, { pos[1] + 1, pos[2] })
        end
    end

	table.insert(self.history, self.marks[mark_id])
	if #self.history > 2 then
		table.remove(self.history, 1)
	end
end

function M:delete_by(key, value)
	local m = fun.iter(self.marks)
		:filter(function(_, ma)
			return ma[key] == value
		end)
		:totable()[1]

	-- TODO: check if setting the value as nil only in the table deletes the instance of the mark 
	self.marks[m]:delete()
	self.marks[m] = nil
end

return M
