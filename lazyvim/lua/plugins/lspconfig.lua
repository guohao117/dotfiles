return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.inlay_hints.enabled = false
    opts.diagnostics.virtual_text = false
  end,
}
