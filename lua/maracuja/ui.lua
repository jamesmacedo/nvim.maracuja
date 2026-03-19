local state = require("maracuja.models.state")
local config = require("maracuja.config")
local move = require("maracuja.logic.movement")

local UI = {
	lines = {},
	ids = {},
	current_pos = 1
}

local function setup_highlights()
	vim.api.nvim_set_hl(0, "MyMenuBadge", { bg = "#2e3e43", fg = "#89ddff" })
	vim.api.nvim_set_hl(0, "MyMenuSelected", { bg = "#005f87", fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "MyMenuFile", { fg = "#ebdbb2" })
end

function UI.draw()

	vim.api.nvim_buf_clear_namespace(state.buffer, config.ui, 0, -1)

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

		if UI.current_pos == i then
			vim.api.nvim_buf_add_highlight(state.buffer, config.ui, "MyMenuFile", i - 1, 0, -1)
		end
	end
end

function UI.delete()
	local m = state.marks[UI.ids[UI.current_pos]]
	if m ~= nil then
		m:delete()
		vim.api.nvim_win_close(UI.window, true)
	end
end

function UI.move(step)
	local new_pos = UI.current_pos + step
	if (new_pos > 0 and new_pos <= #UI.lines) then
		UI.current_pos = new_pos
	end

	vim.notify(tostring(UI.current_pos))
	UI.draw()
end

function UI.show_window()
	setup_highlights()

	UI.lines = {}
	UI.ids = {}

	local original_guicursor = vim.opt.guicursor:get()

	vim.api.nvim_set_hl(0, "HiddenCursor", { blend = 100, nocombine = true })

	local width = 40
	local height = #state.orders

	for pos, item in ipairs(state.orders) do
		table.insert(UI.lines, " " .. state.marks[item].line:sub(0, 30))
		UI.ids[pos] = state.marks[item].id
	end

	-- UI.current_pos = #UI.lines

	vim.api.nvim_buf_set_lines(state.buffer, 0, -1, false, UI.lines)

	vim.api.nvim_create_autocmd("BufEnter", {
		buffer = state.buffer,
		callback = function ()
			vim.opt.guicursor = "a:HiddenCursor"
		end
	})

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = state.buffer,
		callback = function ()
			vim.opt.guicursor = original_guicursor
		end
	})

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
		local m = state.marks[UI.ids[UI.current_pos]]

		if m ~= nil then
			move.jump_to(m.id)
		end

		vim.api.nvim_win_close(UI.window, true)
	end)

	local opts = { buffer = state.buffer, noremap = true, silent = true }
	vim.keymap.set("n", "<Up>", function() UI.move(-1) end, opts)
	vim.keymap.set("n", "<Down>", function() UI.move(1) end, opts)
	vim.keymap.set("n", "d", function() UI.delete() end, opts)


	UI.draw()
	-- vim.api.nvim_win_set_option(UI.window, "cursorline", true)
	-- vim.api.nvim_win_set_option(UI.window, "winhl", "Normal:NormalFloat,CursorLine:MyMenuSelected")
end

return UI
