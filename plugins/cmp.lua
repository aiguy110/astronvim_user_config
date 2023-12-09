return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    opts.mapping['<Tab>'] = nil -- Unmap <Tab> so Copilot can use it
    return opts
  end
}
