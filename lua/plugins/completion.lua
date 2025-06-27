return {
  {
    "saghen/blink.cmp",
    version = not vim.g.lazyvim_blink_main and "*",
    build = vim.g.lazyvim_blink_main and "cargo build --release",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip",
    },
    event = "InsertEnter",
    
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = function(_, opts)
        opts.sources.compat = nil
	    snippets = { preset = "luasnip" }
      opts.appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      }
      opts.keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
      }

      opts.sources = {
	default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            enabled = true,
            transform_items = function(_, items)
              return vim.tbl_filter(function(item)
                return item.kind ~= require("blink.cmp.types").CompletionItemKind.Text
              end, items)
            end,
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = -3,
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              get_cwd = function(context)
                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
              end,
              show_hidden_files_by_default = false,
            },
          },
         snippets = {
           name         = "Snippets",
           module       = "blink.cmp.sources.snippets",
           score_offset = -1,
         },
	  buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            score_offset = -2,
            opts = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
            },
          },
        },
      }

      opts.completion = {
        accept = {
          create_undo_point = true,
          auto_brackets = {
            enabled = true,
            default_brackets = { "(", ")" },
            override_brackets_for_filetypes = {},
            force_allow_filetypes = {},
            blocked_filetypes = {},
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            },
            semantic_token_resolution = {
              enabled = true,
              blocked_filetypes = {},
            },
          },
        }
}
        opts.cmdline = {
          enabled = false,
        }



      signature = {
        enabled = true,
        window = {
          min_width = 1,
          max_width = 100,
          max_height = 10,
          border = "padded",
          winblend = 0,
          winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
          scrollbar = false,
        },
      }
      return opts
end,
    config = function(_, opts)
      require("blink.cmp").setup(opts)
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    build = (function()
      if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
        return
      end
      return "make install_jsregexp"
    end)(),
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },
}

