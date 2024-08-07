local tree = require("nvim-tree.api")

vim.g.mapleader = " "

local map = vim.api.nvim_set_keymap
local opts = { noremap = false, silent = true }

-- nvim-tree keys

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>e", function()
	tree.tree.toggle()
end)
vim.keymap.set("n", "<leader>t", function()
	tree.tree.focus()
end)

-- Special shortcuts for neovide

local counter = 1.0

vim.keymap.set("n", "<C-g>", function()
	counter = counter + 0.10
	vim.g.neovide_scale_factor = counter
end)

vim.keymap.set("n", "<C-f>", function()
	counter = counter - 0.10
	vim.g.neovide_scale_factor = counter
end)

-- Movement keys

map("n", "<leader><Left>", "<Cmd>BufferPrevious<CR>", opts)
map("n", "<leader><Right>", "<Cmd>BufferNext<CR>", opts)
map("n", "<leader>1", "<Cmd>BufferGoto 1<CR>", opts)
map("n", "<leader>2", "<Cmd>BufferGoto 2<CR>", opts)
map("n", "<leader>3", "<Cmd>BufferGoto 3<CR>", opts)
map("n", "<leader>4", "<Cmd>BufferGoto 4<CR>", opts)
map("n", "<leader>5", "<Cmd>BufferGoto 5<CR>", opts)
map("n", "<leader>6", "<Cmd>BufferGoto 6<CR>", opts)
map("n", "<leader>7", "<Cmd>BufferGoto 7<CR>", opts)
map("n", "<leader>8", "<Cmd>BufferGoto 8<CR>", opts)
map("n", "<leader>9", "<Cmd>BufferGoto 9<CR>", opts)
map("n", "<leader>0", "<Cmd>BufferLast<CR>", opts)
map("n", "<leader>c", "<Cmd>BufferClose<CR>", opts)

-- Basic keys
map("v", "<C-C>", '"+y', opts) -- Copy
map("v", "<C-V>", '"+gP', opts) -- Paste
map("v", "<C-X>", '"+x', opts) -- Cut
map("n", "<C-Z>", "u", opts) -- Undo
map("n", "<C-Y>", "<C-R>", opts) -- Redo
