-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness


-- ctrl z to undo last edit
keymap.set("i", "<C-z>", "<C-O>u<CR>")
keymap.set("n", "<C-z>", "u")


-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")


-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab


-- #### visual shifts ####

-- Stay in indent mode
keymap.set("v", "<", "<gv") -- stay in visual mode when shifting
keymap.set("v", ">", ">gv")

keymap.set("x", "<", "<gv") -- stay in visual mode when shifting
keymap.set("x", ">", ">gv")

-- note to self fix visual shift down
keymap.set("v", "<A-k>", ":m-1<CR>gv=gv") -- shift visual block up
keymap.set("v", "<A-up>", ":m-1<CR>gv=gv") -- shift visual block up
keymap.set("v", "<A-j>", ":m+1<CR>gv=gv") -- shift visual block down
keymap.set("v", "<A-down>", ":m+1<CR>gv=gv") -- shift visual block down

keymap.set("x", "<A-k>", ":move '<-2<CR>gv=gv") -- shift visual block up
keymap.set("x", "<A-up>", ":m-2<CR>gv=gv") -- shift visual block up
keymap.set("x", "<A-j>", ":m '>+1<CR>gv=gv") -- shift visual block down
keymap.set("x", "<A-down>", ":m '>+1<CR>gv=gv") -- shift visual block down


-- ## TELESCOPE
-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fs", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- ## Explorer
keymap.set("n", "<leader>e", ":Neotree toggle<CR>", {})
keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
-- oil
keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
