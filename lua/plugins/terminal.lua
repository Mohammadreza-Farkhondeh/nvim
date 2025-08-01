return {
  "akinsho/toggleterm.nvim",
  opts = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local state = { terms = {}, pids = {} }
    local is_win = (vim.loop.os_uname().sysname == "Windows_NT")

    local function project_root()
      local cwd = vim.fn.getcwd()
      local markers = { "Justfile", "justfile", ".git", "package.json", "pyproject.toml" }
      local hit = vim.fs.find(markers, { upward = true, path = cwd })[1]
      return hit and vim.fs.dirname(hit) or cwd
    end

    -- Safely get the PID that Neovim knows for a job
    local function job_pid(job_id)
      local ok, pid = pcall(vim.fn.jobpid, job_id)
      pid = ok and tonumber(pid) or nil
      return (pid and pid > 0) and pid or nil
    end

    -- Get children of a PID, cross-platform (POSIX: pgrep/ps)
    local function children_pids(ppid)
      local seen = {}
      local function add_list(list)
        for _, line in ipairs(list or {}) do
          local n = tonumber(line)
          if n and n > 0 and not seen[n] then
            seen[n] = true
          end
        end
      end

      -- Prefer pgrep -P
      local ok, list = pcall(vim.fn.systemlist, { "pgrep", "-P", tostring(ppid) })
      if ok and vim.v.shell_error == 0 and #list > 0 then
        add_list(list)
      else
        -- Linux ps
        list = vim.fn.systemlist({ "ps", "-o", "pid=", "--ppid", tostring(ppid) })
        if vim.v.shell_error ~= 0 or #list == 0 then
          -- macOS/BSD ps
          list = vim.fn.systemlist({ "ps", "-o", "pid=", "-ppid", tostring(ppid) })
        end
        add_list(list)
      end

      local out = {}
      for pid, _ in pairs(seen) do table.insert(out, pid) end
      return out
    end

    -- Kill a whole process tree, even if children re-parented
    local function kill_tree(pid, sig)
      if not pid or pid <= 0 then return end
      sig = sig or 15  -- 15=SIGTERM, 9=SIGKILL
      if is_win then
        -- Kill process tree on Windows
        pcall(vim.fn.jobstart, { "taskkill", "/T", "/F", "/PID", tostring(pid) })
        return
      end

      -- 1) Try to kill the process group (hits most well-behaved servers)
      pcall(vim.loop.kill, -pid, sig)

      -- 2) Also walk descendants and signal them (covers daemons that changed PGID)
      local seen = {}
      local stack = { pid }
      while #stack > 0 do
        local p = table.remove(stack)
        if not seen[p] then
          seen[p] = true
          pcall(vim.loop.kill, p, sig)
          for _, c in ipairs(children_pids(p)) do
            table.insert(stack, c)
          end
        end
      end
    end

    local function dev_toggle()
      local root = project_root()
      local jf = vim.fs.find({ "Justfile", "justfile" }, { upward = true, path = root })[1]
      if not jf then
        vim.notify("No Justfile found in project root", vim.log.levels.WARN)
        return
      end

      if not state.terms[root] then
        state.terms[root] = Terminal:new({
          -- Use POSIX sh so signals/pgroups behave consistently
          cmd = [[sh -lc 'exec just dev']],
          dir = root,
          direction = "horizontal",
          size = 15,              -- height (lines)
          close_on_exit = false,  -- keep open to see errors
          hidden = true,
          on_open = function() vim.cmd("wincmd h") end, -- keep focus on code
          on_exit = function(term, _, _)
            -- Best-effort sweep on exit of the job's shell
            local pid = job_pid(term.job_id)
            kill_tree(pid, 15)
            vim.defer_fn(function() kill_tree(pid, 9) end, 1200)
          end,
        })
      end

      state.terms[root]:toggle()
      if state.terms[root].job_id then
        state.pids[root] = job_pid(state.terms[root].job_id)
      end
      vim.cmd("wincmd h")
    end

    local function dev_stop()
      local root = project_root()
      local term = state.terms[root]
      if not term then return end

      local pid = job_pid(term.job_id)
      pcall(vim.fn.jobstop, term.job_id) -- politely ask Neovim to stop job
      kill_tree(pid, 15)
      vim.defer_fn(function() kill_tree(pid, 9) end, 1200)
    end

    vim.api.nvim_create_user_command("ProjectDev", dev_toggle, { desc = "Toggle 'just dev' for current project" })
    vim.api.nvim_create_user_command("ProjectDevStop", dev_stop, { desc = "Stop 'just dev' (kills process tree)" })
    vim.keymap.set("n", "<leader>cx", dev_toggle, { desc = "Dev: just dev" })
    vim.keymap.set("n", "<leader>cX", dev_stop, { desc = "Dev: stop just dev" })

    -- Show the tracked PID for the current project
    vim.api.nvim_create_user_command("ProjectDevPID", function()
      local root = project_root()
      local term = state.terms[root]
      if not term then
        vim.notify("No dev terminal for this project", vim.log.levels.INFO)
        return
      end
      local pid = job_pid(term.job_id)
      vim.notify(("ProjectDev PID: %s (job_id=%s)"):format(pid or "?", term.job_id or "?"), vim.log.levels.INFO)
    end, {})

    -- Kill everything we own when Neovim is closing
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        for _, term in pairs(state.terms) do
          if term.job_id then
            local pid = job_pid(term.job_id)
            pcall(vim.fn.jobstop, term.job_id)
            kill_tree(pid, 15)
            vim.defer_fn(function() kill_tree(pid, 9) end, 1200)
          end
        end
      end,
    })
  end,
}

