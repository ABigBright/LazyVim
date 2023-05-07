require("lazyvim.config").init()

return {
    { "folke/lazy.nvim", version = "*" },
    { "ABigBright/LazyVim", 
      branch = 'cus_for_briq',
      priority = 10000, 
      lazy = false, 
      config = true, 
      cond = true, 
      version = "*" },
}
