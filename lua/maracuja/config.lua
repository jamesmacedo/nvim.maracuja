return {
    state = {
        position = 1,
        marks = {},
        orders = {},
        is_menu_open = false
    },
    buffer = vim.api.nvim_create_buf(false, true),
    colors = {
        stale = "#ff00ff",
        active = "#ffffff"
    },
    tracker = vim.api.nvim_create_namespace("mark_tracker"),
    ui = vim.api.nvim_create_namespace("ui"),
}
