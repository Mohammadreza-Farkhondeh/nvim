-- Three calm dark themes with gentle UI overrides and a simple switcher.
-- Default: Kanagawa (Dragon)

local function set_cycle_keymap()
  -- Cycle themes with <leader>ut
  local order = { "kanagawa-dragon", "carbonfox", "everforest" }
  vim.g._theme_index = vim.g._theme_index or 1
  vim.keymap.set("n", "<leader>ut", function()
    vim.g._theme_index = (vim.g._theme_index % #order) + 1
    vim.cmd.colorscheme(order[vim.g._theme_index])
  end, { desc = "Theme: Cycle (quiet dark)" })
end

return {
  ---------------------------------------------------------------------------
  -- 1) KANAGAWA (Dragon) – deep, earthy, very readable, non-glossy
  ---------------------------------------------------------------------------
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      compile = false,
      transparent = false,
      dimInactive = true,
      terminalColors = true,
      undercurl = false,
      commentStyle = { italic = false },
      keywordStyle = { italic = false },
      statementStyle = { bold = false },
      typeStyle = {},
      colors = {
        theme = { all = { ui = { bg_gutter = "none" } } }, -- remove left gutter tint
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          NormalFloat = { bg = theme.ui.bg_m3 },
          FloatBorder = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
          Pmenu = { bg = theme.ui.bg_p1, fg = theme.ui.shade0 },
          PmenuSel = { bg = theme.ui.bg_p2, fg = theme.ui.shade0 },
          CursorLine = { bg = theme.ui.bg_m2 },
          Visual = { bg = theme.ui.bg_p2 },
          WinSeparator = { fg = theme.ui.bg_m3 },
          TelescopeNormal = { bg = theme.ui.bg_m3 },
          TelescopeBorder = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
          TelescopePromptNormal = { bg = theme.ui.bg_p1 },
          TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
          TelescopeResultsNormal = { bg = theme.ui.bg_m3 },
          TelescopePreviewNormal = { bg = theme.ui.bg_m3 },
          LspInlayHint = { fg = theme.ui.special, bg = theme.ui.bg_m3 },
          DiagnosticVirtualTextError = { fg = colors.palette.samuraiRed, bg = "NONE" },
          DiagnosticVirtualTextWarn = { fg = colors.palette.roninYellow, bg = "NONE" },
          DiagnosticVirtualTextInfo = { fg = colors.palette.waveAqua2, bg = "NONE" },
          DiagnosticVirtualTextHint = { fg = colors.palette.dragonBlue, bg = "NONE" },
        }
      end,
    },
    config = function(_, opts)
      -- sensible globals
      vim.opt.termguicolors = true
      vim.opt.background = "dark"

      require("kanagawa").setup(opts)
      vim.cmd("colorscheme kanagawa-dragon")

      -- Commands to switch explicitly (defined here so no fake plugin is needed)
      vim.api.nvim_create_user_command("ThemeKanagawa", function()
        vim.cmd("colorscheme kanagawa-dragon")
      end, {})

      vim.api.nvim_create_user_command("ThemeCarbonfox", function()
        require("lazy").load({ plugins = { "nightfox.nvim" } })
        vim.cmd("colorscheme carbonfox")
      end, {})

      vim.api.nvim_create_user_command("ThemeEverforest", function()
        require("lazy").load({ plugins = { "everforest-nvim" } })
        vim.cmd("colorscheme everforest")
      end, {})

      set_cycle_keymap()
    end,
  },

  ---------------------------------------------------------------------------
  -- 2) NIGHTFOX (Carbonfox) – charcoal & muted; excellent for long sessions
  ---------------------------------------------------------------------------
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    opts = {
      options = {
        transparent = false,
        dim_inactive = true,
        terminal_colors = true,
        styles = {
          comments = "NONE",
          keywords = "NONE",
          types = "NONE",
          functions = "NONE",
          conditionals = "NONE",
          constants = "NONE",
          variables = "NONE",
          numbers = "NONE",
          strings = "NONE",
        },
        inverse = { match_paren = false, visual = false, search = false },
        modules = {
          telescope = true,
          lsp_trouble = true,
          native_lsp = true,
          treesitter = true,
          cmp = true,
          gitsigns = true,
        },
      },
      groups = {
        all = {
          NormalFloat = { bg = "bg3" },
          FloatBorder = { fg = "bg3", bg = "bg3" },
          Pmenu = { bg = "bg2" },
          PmenuSel = { bg = "bg3" },
          CursorLine = { bg = "bg2" },
          WinSeparator = { fg = "bg3" },
          TelescopeNormal = { bg = "bg3" },
          TelescopeBorder = { fg = "bg3", bg = "bg3" },
          LspInlayHint = { bg = "bg3" },
        },
      },
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
      -- colorscheme set by the command defined in Kanagawa's config
    end,
  },

  ---------------------------------------------------------------------------
  -- 3) EVERFOREST (hard) – calm forest palette, low-contrast UI
  ---------------------------------------------------------------------------
  {
    "neanias/everforest-nvim",
    lazy = true,
    version = false,
    opts = {
      background = "hard",
      transparent_background_level = 0,
      italics = false,
      disable_italic_comments = true,
      sign_column_background = "none",
      dim_inactive_windows = true,
      ui_contrast = "low", -- keep UI subdued
      on_highlights = function(hl, p)
        hl.NormalFloat = { bg = p.bg_dim }
        hl.FloatBorder = { fg = p.bg_dim, bg = p.bg_dim }
        hl.Pmenu = { bg = p.bg1, fg = p.fg }
        hl.PmenuSel = { bg = p.bg2, fg = p.fg }
        hl.CursorLine = { bg = p.bg1 }
        hl.WinSeparator = { fg = p.bg_dim }
        hl.TelescopeNormal = { bg = p.bg_dim }
        hl.TelescopeBorder = { fg = p.bg_dim, bg = p.bg_dim }
        hl.LspInlayHint = { fg = p.grey2, bg = p.bg_dim }
        hl.DiagnosticVirtualTextError = { fg = p.red, bg = "NONE" }
        hl.DiagnosticVirtualTextWarn = { fg = p.yellow, bg = "NONE" }
        hl.DiagnosticVirtualTextInfo = { fg = p.green, bg = "NONE" }
        hl.DiagnosticVirtualTextHint = { fg = p.blue, bg = "NONE" }
      end,
    },
    config = function(_, opts)
      require("everforest").setup(opts)
      -- colorscheme set by the command defined in Kanagawa's config
    end,
  },
}
