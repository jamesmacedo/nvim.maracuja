local C = {
	open = false,
	lines = {},
	ids = {},
	current_pos = 1,
	window = nil,
	original_guicursor = nil,
	events_done = false,
}

local PADDING = 5

C.MAX_COL_ROWS = 35

C.WIDTH = C.MAX_COL_ROWS + PADDING
C.GROUP = vim.api.nvim_create_augroup("MaracujaUI", { clear = true })
C.BUFFER = vim.api.nvim_create_buf(false, true)

return C
