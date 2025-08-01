return {
  {
    "stevearc/conform.nvim",
    opts = {
      -- format_on_save = { timeout_ms = 1000, lsp_fallback = true },

      formatters_by_ft = {
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },

        javascript = { "prettierd", "prettier", "eslint_d" },
        javascriptreact = { "prettierd", "prettier", "eslint_d" },
        typescript = { "prettierd", "prettier", "eslint_d" },
        typescriptreact = { "prettierd", "prettier", "eslint_d" },
        astro = { "prettierd", "prettier", stop_after_first = true },

        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },

        lua = { "stylua" },
        json = { "prettierd", "prettier", stop_after_first = true },

        yaml = { "yamlfmt", "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },

        rust = { "rustfmt" },
        go = { "gofumpt", "goimports", "golines" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        sh = { "shfmt" },
        dockerfile = {},
      },

      formatters = {
        rustfmt = { command = "rustfmt", args = { "--emit=stdout" } },
        clang_format = { command = "clang-format", args = {} },
        shfmt = { command = "shfmt", args = { "-i", "2" } },

        -- Run eslint_d only if a config file exists
        eslint_d = {
          condition = function(ctx)
            return vim.fs.find({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.json",
              ".eslintrc.yaml",
              ".eslintrc.yml",
            }, { upward = true, path = ctx.dirname })[1] ~= nil
          end,
        },

        yamlfmt = { command = "yamlfmt" },

        ruff_organize_imports = {
          command = "ruff",
          args = { "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "-" },
          stdin = true,
        },
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- JS/TS/HTML/CSS
        "prettierd",
        "eslint_d",
        -- Python
        "ruff",
        -- Lua
        "stylua",
        -- Shell
        "shfmt",
        -- Go
        "gofumpt",
        "goimports",
        "golines",
        -- Rust
        "rustfmt",
        -- C/C++
        "clang-format",
        -- YAML
        "yamlfmt",
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}
