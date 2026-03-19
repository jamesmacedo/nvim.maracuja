local config = require("maracuja.config")
local helpers = require("maracuja.helpers")
local state = require("maracuja.models.state")

local fun = require("maracuja.vendor.fun")

local Mark = {}

function Mark:delete()
	vim.api.nvim_buf_del_extmark(self.buf, config.tracker, self.pos_id)

	vim.fn.sign_unplace("signals", {
		id = self.signal_id,
		buffer = self.buf,
	})

	state.marks[self.id] = nil

	state.orders = fun.iter(state.orders):filter(function(id)
		return id ~= self.id
	end):totable()

    -- vim.notify("Mark " .. self.id .. " deleted with sucess.")
end

function Mark.new()
	local self = setmetatable({}, { __index = Mark })

	self.buf = vim.api.nvim_get_current_buf();
	self.win = vim.api.nvim_get_current_win()

	local pos = vim.api.nvim_win_get_cursor(0)

	local raw_line = vim.api.nvim_buf_get_lines(self.buf, pos[1] - 1, pos[1] + 1, false)[1]

	self.line = vim.trim(raw_line)

	if self.line == '' or self.line == nil then
		vim.notify("Empty line")
		return nil
	end

	local ids = {}

	for _, ord in pairs(state.orders) do
		table.insert(ids, state.marks[ord].id)
	end

	local i = 1
	for char in self.line:gmatch(".") do
		if helpers.tabl.has_value(ids, char) == false then
			self.id = self.line:sub(i, i)
			break
		end
		i = i + 1
	end

	local max_col = #raw_line
	local safe_col = math.min(pos[2], max_col)

	-- vim.notify(("Row: %d - Col %d"):format(pos[1], safe_col))

	self.pos_id = vim.api.nvim_buf_set_extmark(self.buf, config.tracker, pos[1] - 1, safe_col, {})

	local id = "signal_" .. self.id

	vim.fn.sign_define(id, {
		text = self.id,
		texthl = "signal_fg",
		numhl = "signal_fg",
	})

	self.signal_id = vim.fn.sign_place(0, "signals", id, self.buf, { lnum = pos[1], priority = 2 })

	state.marks[self.id] = self
	table.insert(state.orders, self.id)

	return self
end

return Mark
