local state = require("maracuja.models.state")
local config = require("maracuja.config")
local move = require("maracuja.logic.movement")

local UI = {}

local function setup_highlights()
	vim.api.nvim_set_hl(0, "MyMenuBadge", { bg = "#2e3e43", fg = "#89ddff" })
	vim.api.nvim_set_hl(0, "MyMenuSelected", { bg = "#005f87", fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "MyMenuFile", { fg = "#ebdbb2" })
end

function UI.show_window()
	setup_highlights()

	local width = 40
	local height = #state.orders

	local lines = {}
	local ids = {}

	for pos, item in ipairs(state.orders) do
		table.insert(lines, " " .. state.marks[item].line:sub(0, 30))
		ids[pos] = state.marks[item].id
	end

	vim.api.nvim_buf_set_lines(state.buffer, 0, -1, false, lines)

	for i, item in ipairs(state.orders) do
		local badge_hl = "MyMenuBadge"
		if i == 2 then
			badge_hl = "MyMenuSelected"
		end

		vim.api.nvim_buf_set_extmark(state.buffer, config.ui, i - 1, 0, {
			virt_text = { { " " .. state.marks[item].id .. " ", badge_hl } },
			virt_text_pos = "inline",
			hl_mode = "combine",
		})

		vim.api.nvim_buf_add_highlight(state.buffer, config.ui, "MyMenuFile", i - 1, 0, -1)
	end

	UI.window = vim.api.nvim_open_win(state.buffer, true, {
		relative = "cursor",
		width = width,
		height = height,
		row = 1,
		col = 0,
		-- style = "minimal",
		border = "none",
	})

	vim.keymap.set("n", "<CR>", function()
		local pos = vim.api.nvim_win_get_cursor(0)[1]

		local m = state.marks[ids[pos]]

		if m ~= nil then
			move.jump_to(m.id)
		end

		vim.api.nvim_win_close(UI.window, true)
	end)

	-- vim.api.nvim_win_set_option(UI.window, "cursorline", true)
	-- vim.api.nvim_win_set_option(UI.window, "winhl", "Normal:NormalFloat,CursorLine:MyMenuSelected")
end

return UI
