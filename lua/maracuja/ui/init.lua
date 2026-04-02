local config = require("maracuja.config")
local helpers = require("maracuja.helpers")
local modes = require("maracuja.modes")
local fun = require("maracuja.vendor.fun")

local ui_config = require("maracuja.ui.config")

local UI = {}

local function setup_highlights()
	vim.api.nvim_set_hl(0, "RewindBadge", { bg = "#1f2a2e", fg = "#89ddff", default = true })
	vim.api.nvim_set_hl(0, "MyMenuBadge", { bg = "#2e3e43", fg = "#89ddff", default = true })
	vim.api.nvim_set_hl(0, "MyMenuSelected", { bg = "#005f87", fg = "#ffffff", default = true })
	vim.api.nvim_set_hl(0, "MyMenuFile", { fg = "#ebdbb2", default = true })
	vim.api.nvim_set_hl(0, "HiddenCursor", { blend = 100, nocombine = true, default = true })
end

function UI:close()
	vim.api.nvim_win_close(self.window, true)
	config.state.is_menu_open = false
end

function UI:draw()
	vim.api.nvim_buf_clear_namespace(ui_config.BUFFER, config.ui, 0, -1)

	for i, line in pairs(self.lines) do
		local badge_hl = "MyMenuBadge"

		if self.current_pos == i then
			badge_hl = "MyMenuSelected"
			vim.api.nvim_buf_add_highlight(ui_config.BUFFER, config.ui, "MyMenuFile", i - 1, 0, -1)
		end

		-- local icon = i == 1 and #config.state.history == 2 and "󰑟" or line.id
		-- local color = i == 1 and "RewindBadge" or badge_hl

		vim.api.nvim_buf_set_extmark(ui_config.BUFFER, config.ui, i - 1, 0, {
			virt_text = { { " " .. line.id .. " ", badge_hl } },
			virt_text_pos = "inline",
			hl_mode = "combine",
		})
	end
end

function UI:delete()
	local m = config.state.marks[self.lines[self.current_pos].id]
	if m ~= nil then
		m:delete()
		self:close()
	end
end

function UI:move(step)
	local new_pos = self.current_pos + step
	if new_pos > 0 and new_pos <= #self.lines then
		self.current_pos = new_pos
	end
	self:draw()
end

function UI:setup_events()
	if self.events_done then
		return
	end

	self.original_guicursor = vim.opt.guicursor:get()

	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		group = ui_config.GROUP,
		buffer = ui_config.BUFFER,
		callback = function()
			vim.opt.guicursor = "a:HiddenCursor"
		end,
	})

	vim.api.nvim_create_autocmd({ "WinClosed", "BufLeave" }, {
		group = ui_config.GROUP,
		buffer = ui_config.BUFFER,
		callback = function()
			vim.opt.guicursor = self.original_guicursor
		end,
	})

	self.events_done = true
end

function UI:toggle_menu()

	local mode, is_available = modes.get_mode()

	if is_available == false then
		vim.notify("No marks found")
		return
	end

	config.state.is_menu_open = true

	setup_highlights()

	UI.current_pos = 1

	vim.api.nvim_buf_set_option(ui_config.BUFFER, "modifiable", true)

	local lines, height = mode:get_lines()

	self.lines = lines

	local p_lines = fun.map(function(value)
        return value.content
    end, lines):totable()

	vim.api.nvim_buf_set_lines(ui_config.BUFFER, 0, -1, false, p_lines)

	self:setup_events()

	self.window = vim.api.nvim_open_win(ui_config.BUFFER, true, {
		relative = "cursor",
		width = ui_config.WIDTH,
		height = height,
		row = 1,
		col = 1,
		style = "minimal",
		border = "none",
	})

	vim.api.nvim_buf_set_option(ui_config.BUFFER, "modifiable", false)

	local opts = { buffer = ui_config.BUFFER, noremap = true, silent = true }

	vim.keymap.set("n", "<CR>", function()
		mode:on_select(self.lines[self.current_pos].id)
		self:close()
	end)

	vim.keymap.set("n", "s", function()
		mode:switch()
		self:close()
	end, opts)

	vim.keymap.set("n", "<Up>", function()
		self:move(-1)
	end, opts)
	vim.keymap.set("n", "<Down>", function()
		self:move(1)
	end, opts)
	vim.keymap.set("n", "d", function()
		self:delete()
	end, opts)

	vim.keymap.set("n", "<Esc>", function()
		self:close()
	end, opts)

	-- vim.keymap.set("n", "t", function()
	-- 	vim.notify("modo temporal")
	-- 	self:close()
	-- 	UI:toggle_menu()
	-- end, opts)

	self:draw()
end

return UI
