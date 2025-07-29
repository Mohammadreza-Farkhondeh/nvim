return {
  "neovim/nvim-lspconfig",
  event = "LazyFile",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  opts = function()
    return {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
      },

      inlay_hints = { enabled = true },
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },

      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              hint = { enable = true },
              completion = { callSnippet = "Replace" },
            },
          },
        },

        -- Enhanced Python configuration
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "strict",
                reportUnusedImport = false,
                reportUnusedVariable = false,
                reportDuplicateImport = false,
                reportMissingImports = true,
                reportUndefinedVariable = true,
                autoImportCompletions = true,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },

        ruff = {
          init_options = { 
            settings = { 
              args = {},
              -- Enable additional ruff features
              organizeImports = true,
            } 
          },
        },

        -- TypeScript/JavaScript support
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },

        -- ESLint for additional JavaScript/TypeScript linting
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
          },
        },

        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
            },
          },
        },

        clangd = {
          cmd = { "clangd", "--offset-encoding=utf-16" },
        },

        gopls = {
          settings = {
            gopls = {
              analyses = { unusedparams = true, nilness = true },
              gofumpt = true,
            },
          },
        },
      },

      mason = {
        ensure_installed = {
          -- Python
          "pyright",
          "ruff",
          -- TypeScript/JavaScript
          "typescript-language-server",
          "eslint-lsp",
          -- Other languages
          "rust_analyzer",
          "clangd",
          "gopls",
          "lua-language-server",
        },
        automatic_installation = true,
      },
    }
  end,
  config = function(_, opts)
    LazyVim.lsp.setup(opts)
    LazyVim.format.register(LazyVim.lsp.formatter())

    LazyVim.lsp.on_attach(function(client, buffer)
      require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)

      -- Python-specific configurations
      if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end

      if client.name == "pyright" then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      -- TypeScript-specific configurations
      if client.name == "ts_ls" then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end
    end)

    -- LazyVim.lsp.setup()
    LazyVim.lsp.on_dynamic_capability(require("lazyvim.plugins.lsp.keymaps").on_attach)

    vim.diagnostic.config(opts.diagnostics)
    local servers = opts.servers
    local capabilities = vim.tbl_deep_extend(
      "force",
      vim.lsp.protocol.make_client_capabilities(),
      require("blink.cmp").get_lsp_capabilities(),
      opts.capabilities or {}
    )

    local function setup(server)
      local server_opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
      }, servers[server] or {})
      require("lspconfig")[server].setup(server_opts)
    end

    local has_mason, mlsp = pcall(require, "mason-lspconfig")
    if has_mason then
      mlsp.setup({
        ensure_installed = vim.tbl_keys(servers),
        handlers = { setup },
        automatic_installation = true,
      })
    else
      for server, _ in pairs(servers) do
        setup(server)
      end
    end
  end,
}
