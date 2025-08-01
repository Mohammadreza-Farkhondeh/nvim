return {
  "neovim/nvim-lspconfig",
  event = "LazyFile",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "b0o/schemastore.nvim",
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
          fileOperations = { didRename = true, willRename = true },
        },
      },

      servers = {
        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              hint = { enable = true },
              completion = { callSnippet = "Replace" },
            },
          },
        },

        -- Python
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
            settings = { args = {}, organizeImports = true },
          },
        },

        -- TypeScript / JavaScript
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
        eslint = { settings = { workingDirectories = { mode = "auto" } } },

        -- Web stack
        html = {},
        cssls = {},
        emmet_ls = {
          filetypes = {
            "html",
            "css",
            "scss",
            "less",
            "javascriptreact",
            "typescriptreact",
            "astro",
            "svelte",
          },
        },
        tailwindcss = {
          filetypes = { "astro", "html", "css", "scss", "less", "javascriptreact", "typescriptreact" },
          init_options = {
            userLanguages = { astro = "astro" },
          },
        },
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = { enable = false, url = "" },
              schemas = require("schemastore").yaml.schemas(),
              keyOrdering = false,
            },
          },
        },
        astro = {},

        -- Infra
        dockerls = {},
        docker_compose_language_service = {},
        bashls = {},

        -- Systems & others
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
            },
          },
        },
        clangd = { cmd = { "clangd", "--offset-encoding=utf-16" } },
        gopls = {
          settings = {
            gopls = {
              analyses = { unusedparams = true, nilness = true },
              gofumpt = true,
            },
          },
        },
        marksman = {}, -- markdown
      },
    }
  end,

  config = function(_, opts)
    LazyVim.lsp.setup(opts)
    LazyVim.format.register(LazyVim.lsp.formatter())

    LazyVim.lsp.on_attach(function(client, buffer)
      require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)

      -- Avoid LSP formatting conflicts; formatting handled by conform.nvim
      local function disable_fmt()
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end

      if
        client.name == "pyright"
        or client.name == "ts_ls"
        or client.name == "eslint"
        or client.name == "jsonls"
        or client.name == "yamlls"
        or client.name == "html"
        or client.name == "cssls"
      then
        disable_fmt()
      end
    end)

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
      local server_opts =
        vim.tbl_deep_extend("force", { capabilities = vim.deepcopy(capabilities) }, servers[server] or {})
      require("lspconfig")[server].setup(server_opts)
    end

    local ok, mlsp = pcall(require, "mason-lspconfig")
    if ok then
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
