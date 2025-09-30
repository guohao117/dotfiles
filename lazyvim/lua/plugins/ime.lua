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
  },
}
