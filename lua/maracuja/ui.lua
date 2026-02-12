local UI = {}

UI.window = nil
UI.buf = nil
UI.ns_id = vim.api.nvim_create_namespace("meu_plugin_ui")

function UI.setup_lateral()
	vim.opt.signcolumn = "yes:2"
	local buf = vim.api.nvim_get_current_buf()

	vim.fn.sign_define("MeuSinalCustomizado", {
		text = "l",
		texthl = "WarningMsg",
		numhl = "WarningMsg"
	})

	local linha_desejada = 5

	vim.fn.sign_place(
		0,
		"MeuGrupoDeSinais",
		"MeuSinalCustomizado",
		buf,
		{ lnum = linha_desejada, priority = 2 }
	)
end

return UI
