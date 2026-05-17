return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")
      config.setup({
        auto_install = true,
        ensure_installed = {'html', 'gdscript', 'godot_resource', 'gdshader',"lua", "javascript"},
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  }
  -- {'habamax/vim-godot', event ='VimEnter'},
}

