local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("options")
require("keymaps")
require("lazy").setup("plugins")


--if vim.fn.filereadable(vim.fn.getcwd() .. 'project.godot') == 1 then
 -- local addr = './godot.pipe'
 -- if vim.fn.has 'win32' == 1 then
 --   addr = '127.0.0.1:6004'
 -- end
 -- vim.fn.serverstart(addr)
--end

--local cmd = { "godot-wsl-lsp" }
--local pipe = "/tmp/godot.pipe"
--
--vim.lsp.start({
--    name = "Godot",
--    cmd = cmd,
--    filetypes = { "gdscript" },
--    root_dir = vim.fs.dirname(vim.fs.find({ "project.godot", ".git" }, {
--        upward = true,
--        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
--    })[1]),
--    on_attach = function(client, bufnr)
--        vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
--    end
--})
