local P = {}

P.Marks = {}

local tracker = vim.api.nvim_create_namespace('mark_tracker')

local Mark = {}

vim.opt.signcolumn = "yes:2"

local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
vim.api.nvim_set_hl(0, "signal_fg", { fg = comment_hl.fg, bold = true })

function Mark:delete()

	vim.api.nvim_buf_del_extmark(self.buffer, tracker, self.pos_id)

	vim.fn.sign_unplace("signals", {
		id = self.signal_id,
		buffer = self.buffer
	})

end

function Mark.new()
	local self = setmetatable({}, { __index = Mark })
	local pos = vim.api.nvim_win_get_cursor(0)

	local raw_line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1] + 1, false)[1]

	vim.notify(raw_line)

	local line = vim.trim(raw_line)

	self.id = line:sub(1, 1)
	self.buffer = vim.api.nvim_get_current_buf()


	local max_col = #raw_line
	local safe_col = math.min(pos[2], max_col)

	vim.notify(("Row: %d - Col %d"):format(pos[1], safe_col))

	self.pos_id = vim.api.nvim_buf_set_extmark(0, tracker, pos[1]-1, safe_col, {})

	local id = "signal_" .. self.id

	vim.fn.sign_define(id, {
		text = self.id,
		texthl = "signal_fg",
		numhl = "signal_fg"
	})

	self.signal_id = vim.fn.sign_place(
		0,
		"signals",
		id,
		self.buffer,
		{ lnum = pos[1], priority = 2 }
	)

	return self
end

function P.keymap()
	vim.api.nvim_set_keymap("n", "<leader>]", ":MarkCircle<CR>", { noremap = true, silent = true})
	vim.api.nvim_set_keymap("n", "]]", ":MarkAdd<CR>", { noremap = true, silent = true })
end

function P.commands()
	vim.api.nvim_create_user_command("MarkAdd", function()

		local c_row = vim.api.nvim_win_get_cursor(0)[1]

		local deleted = false

		local marcas = vim.api.nvim_buf_get_extmarks(0, tracker, 0, -1, {})

		for _, marca in ipairs(marcas) do
			local id = marca[1]
			local row = marca[2]

			if row == c_row then
				P.Marks[id]:delete()
				P.Marks[id] = nil
				deleted = true
			end
		end

		if deleted then
			return
		end

		local mark = Mark.new()
		P.Marks[mark.pos_id] = mark
		vim.notify("New mark added", vim.log.levels.INFO)
	end, {})

	vim.api.nvim_create_user_command("MarkCircle", function()

		vim.api.nvim_set_hl(0, "signal_fg", { fg = "#ff00ff", bold = true })

		vim.cmd("redraw")

		local ok, char = pcall(vim.fn.getcharstr)

		vim.api.nvim_set_hl(0, "signal_fg", { fg = "#ffffff", bold = true })

		vim.cmd("redraw")

		if ok then
			-- Start circle
			if char == "]" then

				while char == "]" do
					local _, char = pcall(vim.fn.getcharstr)

				end

				
			end

			vim.notify("Choosen char: " .. char)
			for _, mark in ipairs(P.Marks) do
				if mark.id == char then
					local pos = vim.api.nvim_buf_get_extmark_by_id(0, tracker, mark.pos_id, {})
					vim.api.nvim_win_set_cursor(0, {pos[1]+1, pos[2]})
					break;
				end
			end

		end

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
-- require("maracuja.ui").setup_lateral()

return P
