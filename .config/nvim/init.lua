-- options
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true

-- plugins
vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/vyfor/cord.nvim",
})

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

-- deps-lsp
local function deps_lsp_install_args(force)
	local args = { "cargo", "install", "deps-lsp", "--locked", "--no-default-features", "--features", "cargo,npm" }
	if force then
		table.insert(args, "--force")
	end
	return args
end

local function ensure_deps_lsp()
	if vim.fn.executable("deps-lsp") == 0 then
		vim.notify("Installing deps-lsp...", vim.log.levels.INFO)
		vim.system(deps_lsp_install_args(false), { text = true }, function(obj)
			vim.schedule(function()
				local level = obj.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
				vim.notify(obj.code == 0 and "deps-lsp installed" or obj.stderr, level)
			end)
		end)
	end
end

ensure_deps_lsp()

vim.api.nvim_create_user_command("DepsLspUpdate", function()
	vim.system(deps_lsp_install_args(true), { text = true }, function(obj)
		vim.schedule(function()
			local level = obj.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
			vim.notify(obj.code == 0 and "deps-lsp updated" or obj.stderr, level)
		end)
	end)
end, {})

-- lsp servers
vim.lsp.config("deps_lsp", {
	cmd = { "deps-lsp", "--stdio" },
	filetypes = { "toml", "json" },
	root_markers = { "Cargo.toml", "package.json" },
})

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

vim.lsp.enable("rust_analyzer")
vim.lsp.enable("lua_ls")
vim.lsp.enable("deps_lsp")
