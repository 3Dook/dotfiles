return {
	{ 
		"rose-pine/neovim", 
		name = "rose-pine", 

		config = function()
			require("rose-pine").setup({
				variant = "moon",
				style = {
					transparency = true,
				},
			})
			vim.cmd.colorscheme "rose-pine"
		end
	},
  {
    "xiyaowong/transparent.nvim",
    config = function()
      vim.cmd('TransparentEnable')
    end
  }

}
