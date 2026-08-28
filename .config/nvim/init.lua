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
	"https://github.com/folke/which-key.nvim",
	"https://github.com/saecki/crates.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/vuki656/package-info.nvim",
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

-- dependency management
local crates = require("crates")
crates.setup({
	completion = {
		crates = {
			enabled = true,
		},
	},
	lsp = {
		enabled = true,
		actions = true,
		completion = true,
		hover = true,
	},
})

local pkg_info = require("package-info")
pkg_info.setup()

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
local wk = require("which-key")
wk.setup({
	preset = "classic",
	delay = 200,
})

wk.add({
	{
		"<leader>ih",
		function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end,
		desc = "Toggle inlay hints",
	},
})

wk.add({
	{ "<leader>c", group = "crates" },
	{ "<leader>n", group = "npm" },
	{ "<leader>nu", pkg_info.update, desc = "Update package on line" },
	{ "<leader>nd", pkg_info.delete, desc = "Delete package on line" },
	{ "<leader>ni", pkg_info.install, desc = "Install new package" },
	{ "<leader>np", pkg_info.change_version, desc = "Change package version" },
	{ "<leader>cf", crates.show_features_popup, desc = "Show crate features" },
	{ "<leader>cd", crates.show_dependencies_popup, desc = "Show crate dependencies" },
	{ "<leader>cu", crates.update_crate, desc = "Update crate", mode = "n" },
	{ "<leader>cu", crates.update_crates, desc = "Update crates", mode = "v" },
	{ "<leader>ca", crates.update_all_crates, desc = "Update all crates" },
	{ "<leader>cU", crates.upgrade_crate, desc = "Upgrade crate", mode = "n" },
	{ "<leader>cU", crates.upgrade_crates, desc = "Upgrade crates", mode = "v" },
	{ "<leader>cA", crates.upgrade_all_crates, desc = "Upgrade all crates" },
})
