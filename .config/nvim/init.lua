-- options
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- plugins
vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/vyfor/cord.nvim",
	"https://github.com/navarasu/onedark.nvim",
})

vim.cmd.colorscheme("onedark")

-- diagnostics
vim.diagnostic.config({ virtual_text = false })

require("tiny-inline-diagnostic").setup({
	preset = "simple",
	options = {
		show_source = false,
		multilines = false,
		show_all_diags_on_cursorline = true,
		enable_on_insert = true,
		transparent_bg = true,
	},
})

-- formatting
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },
		toml = { "taplo" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

-- completion
local cmp = require("blink.cmp")
cmp.build():pwait()
cmp.setup({
	keymap = { preset = "default" },
	completion = { documentation = { auto_show = true } },
})

-- lsp servers
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = { command = "clippy" },
		},
	},
})

vim.lsp.config("*", {
	capabilities = cmp.get_lsp_capabilities(),
})

vim.lsp.inlay_hint.enable(true)

vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("ts_ls")

-- keymaps
vim.keymap.set("n", "<leader>ih", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
