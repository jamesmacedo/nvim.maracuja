local config = require("maracuja.config")
local move = require("maracuja.logic.movement")

local UI = {
	open = false,
	lines = {},
	ids = {},
	current_pos = 1,
	window = nil,
	original_guicursor = nil,
	events_done = false
}

local augroup = vim.api.nvim_create_augroup("MaracujaUI", { clear = true })

local function setup_highlights()
	vim.api.nvim_set_hl(0, "MyMenuBadge", { bg = "#2e3e43", fg = "#89ddff", default = true })
	vim.api.nvim_set_hl(0, "MyMenuSelected", { bg = "#005f87", fg = "#ffffff", default = true })
	vim.api.nvim_set_hl(0, "MyMenuFile", { fg = "#ebdbb2", default = true })
	vim.api.nvim_set_hl(0, "HiddenCursor", { blend = 100, nocombine = true, default = true })
end

local function close()
	vim.api.nvim_win_close(UI.window, true)
	config.state.is_menu_open = false
end

function UI.draw()

	vim.api.nvim_buf_clear_namespace(config.buffer, config.ui, 0, -1)

	for i, item in ipairs(config.state.orders) do
		local badge_hl = "MyMenuBadge"
		if i == 2 then
			badge_hl = "MyMenuSelected"
		end

		vim.api.nvim_buf_set_extmark(config.buffer, config.ui, i - 1, 0, {
			virt_text = { { " " .. config.state.marks[item].id .. " ", badge_hl } },
			virt_text_pos = "inline",
			hl_mode = "combine",
		})

		if UI.current_pos == i then
			vim.api.nvim_buf_add_highlight(config.buffer, config.ui, "MyMenuFile", i - 1, 0, -1)
		end
	end
end

function UI.delete()
	local m = config.state.marks[UI.ids[UI.current_pos]]
	if m ~= nil then
		m:delete()
		close()
	end
end

function UI.move(step)
	local new_pos = UI.current_pos + step
	if (new_pos > 0 and new_pos <= #UI.lines) then
		UI.current_pos = new_pos
	end

	UI.draw()
end

function UI:setup_events()

	if self.events_done then
		return
	end

	self.original_guicursor = vim.opt.guicursor:get()

	vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
		group = augroup,
		buffer = config.buffer,
		callback = function ()
			vim.opt.guicursor = "a:HiddenCursor"
			vim.notify("mudando cursor")
		end
	})

	vim.api.nvim_create_autocmd({"WinClosed","BufLeave"}, {
		group = augroup,
		buffer = config.buffer,
		callback = function ()
			vim.opt.guicursor = self.original_guicursor
		end
	})

	self.events_done = true

end

function UI:toggle_menu()

	if not config.state.orders or #config.state.orders == 0 then
		vim.notify("No marks found")
		return
	end

	config.state.is_menu_open = true

	setup_highlights()

	UI.lines = {}
	UI.ids = {}
	UI.current_pos = 1

	local width = 40
	local height = #config.state.orders

	for pos, item in ipairs(config.state.orders) do
		table.insert(UI.lines, " " .. config.state.marks[item].line:sub(0, 30))
		UI.ids[pos] = config.state.marks[item].id
	end

	vim.api.nvim_buf_set_option(config.buffer, 'modifiable', true)

	vim.api.nvim_buf_set_lines(config.buffer, 0, -1, false, UI.lines)

	self:setup_events()

	UI.window = vim.api.nvim_open_win(config.buffer, true, {
		relative = "cursor",
		width = width,
		height = height,
		row = 1,
		col = 0,
		-- style = "minimal",
		border = "none",
	})

	vim.api.nvim_buf_set_option(config.buffer, 'modifiable', false)

	local opts = { buffer = config.buffer, noremap = true, silent = true }

	vim.keymap.set("n", "<CR>", function()
		local m = config.state.marks[UI.ids[UI.current_pos]]

		if m ~= nil then
			move.jump_to(m.id)
		end

		close()
	end)

	vim.keymap.set("n", "<Up>", function() UI.move(-1) end, opts)
	vim.keymap.set("n", "<Down>", function() UI.move(1) end, opts)
	vim.keymap.set("n", "d", function() UI.delete() end, opts)

	vim.keymap.set("n", "<Esc>", function() close() end, opts)

	UI.draw()
end

return UI
