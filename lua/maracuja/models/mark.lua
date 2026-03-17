local config = require("maracuja.config")
local helpers = require("maracuja.helpers")
local state = require("maracuja.models.state")

local Mark = {}

function Mark:delete()
	vim.api.nvim_buf_del_extmark(self.buffer, config.tracker, self.pos_id)

	vim.fn.sign_unplace("signals", {
		id = self.signal_id,
		buffer = self.buffer,
	})
end

function Mark.new()
	local self = setmetatable({}, { __index = Mark })
	local pos = vim.api.nvim_win_get_cursor(0)

	local raw_line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1] + 1, false)[1]

	local line = vim.trim(raw_line)

	if line == '' or line == nil then
		vim.notify("Empty line")
		return nil
	end

	local ids = {}

	for _, mark in ipairs(state.marks) do
		table.insert(ids, mark.id)
	end

	local i = 1
	for char in line:gmatch(".") do
		if helpers.tabl.has_value(ids, char) == false then
			self.id = line:sub(i, i)
			break
		end
		i = i + 1
	end

	self.buffer = vim.api.nvim_get_current_buf()

	local max_col = #raw_line
	local safe_col = math.min(pos[2], max_col)

	-- vim.notify(("Row: %d - Col %d"):format(pos[1], safe_col))

	self.pos_id = vim.api.nvim_buf_set_extmark(0, config.tracker, pos[1] - 1, safe_col, {})

	local id = "signal_" .. self.id

	vim.fn.sign_define(id, {
		text = self.id,
		texthl = "signal_fg",
		numhl = "signal_fg",
	})

	self.signal_id = vim.fn.sign_place(0, "signals", id, self.buffer, { lnum = pos[1], priority = 2 })

	return self
end

return Mark
