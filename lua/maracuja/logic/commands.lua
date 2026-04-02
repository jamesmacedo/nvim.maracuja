local config = require("maracuja.config")
local ui = require("maracuja.ui")
local move = require("maracuja.logic.movement")
local fun = require("maracuja.vendor.fun")
local modes = require("maracuja.modes")

-- local serpent = require("maracuja.vendor.serpent")

return function()
	vim.api.nvim_create_user_command("MarkShow", function()
		if config.state.is_menu_open == false then
			ui:toggle_menu()
		end
	end, {})

	vim.api.nvim_create_user_command("MarkRewind", function()
		local m = config.state.history[2]
		if m ~= nil then
			move.jump_to(m.id)
		end
	end, {})

	vim.api.nvim_create_user_command("MarkGo", function(data)
		move.jump_to(data.fargs[1])
	end, { nargs = 1, desc = "Mark id" })

	vim.api.nvim_create_user_command("MarkToggle", function()

		local mode = modes.get_mode()

		local c_row = vim.api.nvim_win_get_cursor(0)[1]

		local marcas = vim.api.nvim_buf_get_extmarks(0, config.tracker, 0, -1, {})

		for _, marca in ipairs(marcas) do
			local id = marca[1]
			local row = marca[2]
			if row + 1 == c_row then
				mode:delete_by("pos_id", id)
				return
			end
		end
		-- config.add_history(mark.new())
		mode:add_mark()

	end, {})
end
