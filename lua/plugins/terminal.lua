return {
  "akinsho/toggleterm.nvim",
  opts = function(_, opts)
    local Terminal = require("toggleterm.terminal").Terminal
    local function make_term(spec)
      return Terminal:new(vim.tbl_extend("force", {
        direction = "horizontal",  -- right split, not floating
        size      = 30,          -- 30 columns
        hidden    = true,        -- keep it out of :ls
        close_on_exit = false,   -- keep pane open on crash
      }, spec))
    end

    local api_term = make_term({
      name = "API-server",
      dir  = "~/dev/waiotech/wa-api",
      cmd  = "source .venv/bin/activate && uvicorn app:app --reload",
    })

    local dash_term = make_term({
      name = "Dashboard-server",
      dir  = "~/dev/waiotech/wa-dashboard",
      cmd  = "npm run dev",
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local cwd = vim.fn.getcwd()
        if cwd:find("/wa%-api") then
          api_term:toggle()
          vim.cmd("wincmd h")
        elseif cwd:find("/wa%-dashboard") then
          dash_term:toggle()
          vim.cmd("wincmd h")
        end
      end,
    })

    vim.keymap.set("n", "<leader>sa", function() api_term:toggle()  end,
      {desc = "Toggle API server"})
    vim.keymap.set("n", "<leader>sd", function() dash_term:toggle() end,
      {desc = "Toggle Dashboard server"})
  end,
}

