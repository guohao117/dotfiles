return {
  {
    "guohao117/noime.nvim",
    event = "VeryLazy",
    cond = function()
      -- 只在 WezTerm 环境中加载
      return vim.env.WEZTERM_PANE ~= nil or (vim.env.TERM and vim.env.TERM:match("wezterm"))
    end,
    opts = {
      debug = false,
      auto_switch = true,
    },
    config = function(_, opts)
      require("ime-helper").setup(opts)

      -- LazyVim 风格的加载通知
      vim.notify("WezTerm IME Helper loaded", vim.log.levels.INFO, { title = "Plugin" })
    end,
    keys = {
      -- 使用 LazyVim 的 UI 键位前缀 <leader>u
      {
        "<leader>uie",
        function()
          require("ime-helper").switch_to_en()
          vim.notify("Switched to English IME", vim.log.levels.INFO, { title = "IME" })
        end,
        desc = "IME: Switch to English",
      },
      {
        "<leader>uii",
        function()
          require("ime-helper").switch_to_ime()
          vim.notify("Switched to Input Method", vim.log.levels.INFO, { title = "IME" })
        end,
        desc = "IME: Switch to Input Method",
      },
      {
        "<leader>uis",
        function()
          require("ime-helper").status()
        end,
        desc = "IME: Show Status",
      },
    },
  },
}
