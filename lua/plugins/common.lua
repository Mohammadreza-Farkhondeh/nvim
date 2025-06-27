return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "hard" -- "soft", "medium", or "hard"
      vim.g.gruvbox_material_palette = "mix" -- "original", "mix", or "material"
      vim.g.gruvbox_material_enable_bold = 1 -- enable bold text
      vim.g.gruvbox_material_enable_italic = 0 -- enable italic text
      vim.g.gruvbox_material_transparent_background = 0 -- transparent background

      vim.cmd("colorscheme gruvbox-material")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = "gruvbox-material",
        },
      })
    end,
  },
  {
    "snacks.nvim",
    opts = {
      scroll = { enabled = false },
      animate = { enabled = false },
      dashboard = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = false },
      toggle = { map = LazyVim.safe_keymap_set },
      words = { enabled = true },
    },
    keys = {
      {
        "<leader>n",
        function()
          if Snacks.config.picker and Snacks.config.picker then
            Snacks.picker.notifications()
          else
            Snacks.notifier.show_history()
          end
        end,
        desc = "Notification History",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
    },
  },
}
