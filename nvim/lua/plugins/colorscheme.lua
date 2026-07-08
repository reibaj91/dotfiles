-- Custom colorscheme generated from the dotfiles palette (Ghostty / Windows Terminal
-- "BasicDotfiles" scheme) via mini.base16, so Neovim matches the terminal exactly.
-- base00-07 = mono ramp (dark bg -> light fg); base08-0F = accent colors.
return {
  {
    "nvim-mini/mini.base16",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("mini.base16").setup({
        palette = {
          base00 = "#071B22", -- bg               (exact: Ghostty background)
          base01 = "#0E2A33", -- lighter bg        (derived: cursorline / float bg)
          base02 = "#16404D", -- selection bg      (derived: visual selection)
          base03 = "#666666", -- comments          (exact: bright black)
          base04 = "#7C8B8D", -- dim fg / line nr  (exact: Ghostty foreground)
          base05 = "#BFBFBF", -- default fg        (exact: white)
          base06 = "#E5E5E5", -- light fg          (exact: bright white)
          base07 = "#93E6E4", -- lightest accent   (exact: bright cyan)
          base08 = "#E52F31", -- variables/errors  (exact: bright red)
          base09 = "#96993D", -- integers/consts   (exact: yellow)
          base0A = "#E6E45A", -- classes/search    (exact: bright yellow)
          base0B = "#72A52E", -- strings           (exact: green)
          base0C = "#6FB2A9", -- support/regex     (exact: cyan)
          base0D = "#2B8BD2", -- functions         (exact: blue)
          base0E = "#AF6CB0", -- keywords          (exact: magenta)
          base0F = "#990000", -- deprecated        (exact: red)
        },
        use_cterm = true,
      })
      vim.g.colors_name = "basicdotfiles"
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- mini.base16 applies the palette eagerly on startup (priority 1000);
      -- make LazyVim's colorscheme switch a no-op so it doesn't load tokyonight over it.
      colorscheme = function() end,
    },
  },
}
