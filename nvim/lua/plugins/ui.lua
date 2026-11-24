return {
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = true },
      picker = {
        sources = {
          explorer = { hidden = true, ignored = true },
          files = { hidden = true },
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      views = {
        cmdline_popup = {
          position = { row = "33%", col = "50%" },
        },
        cmdline_popupmenu = {
          position = "auto",
        },
      },
    },
  },
}
