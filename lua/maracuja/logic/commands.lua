local config = require("maracuja.config")
local mark = require("maracuja.models.mark")
local state = require("maracuja.models.state")

local ui = require("maracuja.ui")

return function ()
	vim.api.nvim_create_user_command("MarkGo", function(data)
		local marcas = vim.api.nvim_buf_get_extmarks(0, config.tracker, 0, -1, {})

		vim.notify(data.fargs[1])
		local m = mark.where(marcas, data.fargs[1])

		if m ~= nil then
			vim.notify(m.pos_id)
			local pos = vim.api.nvim_buf_get_extmark_by_id(0, config.tracker, m.pos_id, {})
			if next(pos) ~= nil then
				vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
			end
		else
			vim.notify("nil value")
		end
	end, { nargs=1, desc="Mark id"})

	vim.api.nvim_create_user_command("MarkToggle", function()
		local c_row = vim.api.nvim_win_get_cursor(0)[1]

		local marcas = vim.api.nvim_buf_get_extmarks(0, config.tracker, 0, -1, {})

		for _, marca in ipairs(marcas) do
			local id = marca[1]
			local row = marca[2]

			if row + 1 == c_row then
				state.marks[id]:delete()
				state.marks[id] = nil
				state.orders[id] = nil
				return
			end
		end

		local m = mark.new()

		if m ~= nil then
			state.marks[m.pos_id] = m
			table.insert(state.orders, m.pos_id)
		end
	end, {})

	-- vim.api.nvim_create_user_command("MarkCircle", function()
	-- 	vim.api.nvim_set_hl(0, "signal_fg", { fg = config.stale, bold = true })
	--
	-- 	local m = state.marks[state.orders[state.position]]
	--
	-- 	if m then
	-- 		local pos = vim.api.nvim_buf_get_extmark_by_id(0, config.tracker, m.pos_id, {})
	-- 		if next(pos) ~= nil then
	-- 			vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
	-- 		end
	-- 	end
	--
	-- 	vim.cmd("redraw")
	--
	-- 	if state.position < #state.orders then
	-- 		state.position = state.position + 1
	-- 	else
	-- 		state.position = 1
	-- 	end
	-- end, {})
	--
	-- vim.api.nvim_create_user_command("MarkFind", function()
	-- 	vim.api.nvim_set_hl(0, "signal_fg", { fg = config.stale, bold = true })
	-- 	ui.show_menu({
	-- 		{ filename = "ui.lua", key = "u" },
	-- 		{ filename = "init.lua", key = ";" },
	-- 		{ filename = "api.lua", key = "a" },
	-- 	})
	-- end, {})
end
