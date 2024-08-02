-- lsp - a server that will send error diagnositc on our file/codes 
-- formator
-- linters
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
		dependencies = {
      { "hrsh7th/nvim-cmp", lazy = true},
			{ "onsails/lspkind-nvim", lazy = true },
			{ "hrsh7th/cmp-buffer", lazy = true },
			{ "hrsh7th/cmp-cmdline", lazy = true },
			{ "hrsh7th/cmp-nvim-lsp", lazy = true },
			{ "hrsh7th/cmp-path", lazy = true },
			{ "hrsh7th/vim-vsnip", lazy = true },
		},
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require("lspconfig")
      lspconfig.tsserver.setup({
        capabilities = capabilities
      })
      lspconfig.html.setup({
        capabilities = capabilities
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
      -- adding godot functionality to use the godot editor as the lsp server
      lspconfig.gdscript.setup(capabilities)
--      local gdscript_config = {
--        capabilities = capabilities,
--        settings = {},
--      }
--    if vim.fn.has 'win32' == 1 then
--        print('why')
--        -- window specific. requires nmap install ('winget instlal nmap')
--        gdscript_config['cmd'] = { 'ncat', 'localhost', os.getenv 'GDScript_Port' or '6005'}
--      end
--      lspconfig.gdscript.setup(gdscript_config)
      -- https://github.com/lucasecdb/godot-wsl-lsp
     -- lspconfig.gdscript.setup({
     --     cmd = { "godot-wsl-lsp" },
     -- })
      -- LSPinfo - tells you what lsp are connected to the buffer
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
}
