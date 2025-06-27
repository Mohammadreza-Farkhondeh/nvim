return {
  "stevearc/conform.nvim",
  opts = {
    -- format_on_save = { timeout_ms = 1000, lsp_fallback = true },

    formatters_by_ft = {
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
      
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      
      html = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      
      lua = { "stylua" },
      json = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },

      rust = { "rustfmt" },
      go = { "gofumpt", "goimports", "golines" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      sh = { "shfmt" },
    },

    formatters = {
      rustfmt = { 
        command = "rustfmt", 
        args = { "--emit=stdout" } 
      },
      clang_format = { 
        command = "clang-format", 
        args = {} 
      },
      shfmt = { 
        command = "shfmt", 
        args = { "-i", "2" } 
      },
      ruff_organize_imports = {
        command = "ruff",
        args = { "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "-" },
        stdin = true,
      },
    },
  },
}
