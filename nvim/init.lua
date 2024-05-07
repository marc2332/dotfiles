require("plugins")
require("remap")
require("telescope")
print("telescope not loaded")
require("nvim-tree").setup()

-- Just some tweaks for neovide
vim.o.guifont = "JetBrains Mono:h12"
vim.g.neovide_refresh_rate = 60

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.smartident = true
vim.opt.termguicolors = true
vim.o.background = "dark"
vim.cmd([[colorscheme tokyonight]])
vim.opt.nu = true
vim.opt.wrap = false
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes" -- Needed for LSP
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.scrolloff = 3
vim.opt.list = true
vim.opt.listchars = { space = "·", tab = "··", nbsp = "+", trail = "-" }
vim.cmd([[set cursorline]])
vim.cmd("set virtualedit=onemore")
vim.g.gruvbox_flat_style = "hard"

local nvim_tree_events = require("nvim-tree.events")
local bufferline_api = require("bufferline.api")

local function get_tree_size()
	return require("nvim-tree.view").View.width
end

nvim_tree_events.subscribe("TreeOpen", function()
	bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe("Resize", function()
	bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe("TreeClose", function()
	bufferline_api.set_offset(0)
end)

--- LSP

local lsp = require("lsp-zero").preset("minimal")

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	if client.name == "eslint" then
		vim.cmd.LspStop("eslint")
		return
	end

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "<leader>q", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
	vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end)

lsp.setup()

local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()
local lspkind = require("lspkind")

cmp.setup({
	sources = {
		{ name = "path" },
		{ name = "nvim_lsp", keyword_length = 1 },
		{ name = "buffer", keyword_length = 1 },
	},
	mapping = {
		-- `Enter` key to confirm completion
		["<CR>"] = cmp.mapping.confirm({ select = false }),

		-- Ctrl+Space to trigger completion menu
		["<C-Space>"] = cmp.mapping.complete(),
	},
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol",
			maxwidth = 40,
			ellipsis_char = "...",
			symbol_map = {
				Text = "📝",
				Method = "🔨",
				Function = "🔨",
				Constructor = "👷",
				Field = "👈",
				Variable = "🎁",
				Class = "🍷",
				Interface = "",
				Module = "📦",
				Property = "👈",
				Unit = "󰑭",
				Value = "󰎠",
				Enum = "🎲",
				Keyword = "🤔",
				Snippet = "",
				Color = "󰏘",
				File = "󰈙",
				Reference = "🤝",
				Folder = "󰉋",
				EnumMember = "🤏",
				Constant = "🗿",
				Struct = "🧱",
				Event = "",
				Operator = "🧮",
				TypeParameter = "",
			},
			before = function(entry, vim_item)
				return vim_item
			end,
		}),
	},
})

local rt = require("rust-tools")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

rt.setup({
	server = {
		capabilities = capabilities,
		on_attach = function(_, bufnr)
			-- Hover actions
			vim.keymap.set("n", "<leader>c", rt.hover_actions.hover_actions, { buffer = bufnr })
			-- Code action groups
			vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
		end,
	},
})

require("fidget").setup()

require("lualine").setup()

require("treesitter")

require("nvim-autopairs").setup()
