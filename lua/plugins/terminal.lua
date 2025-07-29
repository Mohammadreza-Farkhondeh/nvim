return {
  "akinsho/toggleterm.nvim",
  opts = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local state = { terms = {} }

    local function project_root()
      local cwd = vim.fn.getcwd()
      local markers = { "Justfile", "justfile", ".git", "package.json", "pyproject.toml" }
      local hit = vim.fs.find(markers, { upward = true, path = cwd })[1]
      return hit and vim.fs.dirname(hit) or cwd
    end

    local function dev_toggle()
      local root = project_root()
      -- Check for a Justfile
      local jf = vim.fs.find({ "Justfile", "justfile" }, { upward = true, path = root })[1]
      if not jf then
        vim.notify("No Justfile found in project root", vim.log.levels.WARN)
        return
      end
      if not state.terms[root] then
        state.terms[root] = Terminal:new({
          cmd = "just dev",
          dir = root,
          direction = "horizontal", -- right split
          size = 30,              -- width in columns
          close_on_exit = false,
          hidden = true,
          on_open = function() vim.cmd("wincmd h") end, -- keep focus on code
        })
      end
      state.terms[root]:toggle()
      vim.cmd("wincmd h")
    end

    vim.api.nvim_create_user_command("ProjectDev", dev_toggle, { desc = "Toggle 'just dev' for current project" })
    vim.keymap.set("n", "<leader>sd", dev_toggle, { desc = "Dev: just dev" })
  end,
}

