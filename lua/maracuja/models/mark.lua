local config = require("maracuja.config")
local helpers = require("maracuja.helpers")

local fun = require("maracuja.vendor.fun")

local Mark = {}

function Mark:delete()
	vim.api.nvim_buf_del_extmark(self.buffer, config.tracker, self.pos_id)

	vim.fn.sign_unplace("signals", {
		id = self.signal_id,
		buffer = self.buffer,
	})

	config.state.marks[self.id] = nil

	local new_arr = {}

	fun.iter(config.state.orders):each(function(key, value)
		if value ~= self.id  then
			new_arr[key] = value
		end
	end)

	config.state.orders = new_arr

end

function Mark.new(id, pos, buffer, win)
	local self = setmetatable({}, { __index = Mark })

	local raw_line = vim.api.nvim_buf_get_lines(buffer, pos[1] - 1, pos[1] + 1, false)[1]

	self.line = vim.trim(raw_line)

	if self.line == '' or self.line == nil then
		vim.notify("Empty line")
		return nil
	end

	self.id = id
	self.buffer = buffer
	self.win = win

	local max_col = #raw_line
	local safe_col = math.min(pos[2], max_col)

	-- vim.notify(("Row: %d - Col %d"):format(pos[1], safe_col))

	self.pos_id = vim.api.nvim_buf_set_extmark(self.buffer, config.tracker, pos[1] - 1, safe_col, {})

	local signal_id = "signal_" .. self.id

	vim.fn.sign_define(signal_id, {
		text = self.id,
		texthl = "signal_fg",
		numhl = "signal_fg",
	})

	self.signal_id = vim.fn.sign_place(0, "signals", signal_id, self.buffer, { lnum = pos[1], priority = 2 })

	-- config.state.marks[self.id] = self
	-- config.state.orders[pos[1] - 1] = self.id

	-- local keys_iter = fun.map(function(k, _) return k end, config.state.orders)
	-- local sorted_keys = fun.totable(keys_iter)
	--
	-- table.sort(sorted_keys)

	-- local new_arr = {}

	-- fun.each(function(k)
	-- 	new_arr[k] = config.state.orders[k]
	-- end, sorted_keys)

	-- config.state.orders = new_arr

	return self
end

return Mark
