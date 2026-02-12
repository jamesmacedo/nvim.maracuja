local P = {}

P.Marks = {}

local tracker = vim.api.nvim_create_namespace('mark_tracker')

local Mark = {}

function Mark.new()
	local self = setmetatable({}, { __index = Mark })
	local buf_id = vim.api.nvim_get_current_buf()
	local pos = vim.api.nvim_win_get_cursor(0)

	self.pos_id = vim.api.nvim_buf_set_extmark(0, tracker, pos[1], pos[2], {})

	local line = vim.trim(vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1] + 1, false)[1])

	self.id = line:sub(1, 1)
	self.buffer = buf_id
	return self
end

function P.keymap()
	vim.api.nvim_set_keymap("n", "]", ":MarkCircle<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "]]", ":MarkAdd<CR>", { noremap = true, silent = true })
end

function P.commands()
	vim.api.nvim_create_user_command("MarkAdd", function()
		local mark = Mark.new()
		table.insert(P.Marks, mark)
		vim.notify("New mark added", vim.log.levels.INFO)
	end, {})

	vim.api.nvim_create_user_command("MarkCircle", function()
		vim.notify("Buffer " .. P.Marks[1].buffer, vim.log.levels.INFO)

		-- require("maracuja.ui").create_menu({
		-- 	{ filename = "ui.lua", key = "u" },
		-- 	{ filename = "init.lua", key = ";" },
		-- 	{ filename = "api.lua", key = "a" },
		-- })
	end, {})
end

P.keymap()
P.commands()

-- utils.get_current_buffer()

require("maracuja.ui").setup_lateral()

return P
