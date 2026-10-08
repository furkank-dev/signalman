-- lua/lualine/themes/nazarick.lua
--
-- Mod rengi: normal altin (masaustu), insert krem, visual deniz yesili,
-- command celik. b/c bolumleri notr: durum cubugu kod degil, arayuz.
local c = {
  bg      = '#000000',
  panel   = '#080503',
  fg      = '#D0C9C1',
  muted   = '#877F76',
  dim     = '#6E6860',
  accent  = '#E0B878',
  yellow  = '#EADDBD',
  green   = '#90BDA4',
  rose    = '#70A7C2',
  err     = '#FF7061',
}

return {
  normal = {
    a = { fg = c.bg, bg = c.accent, gui = 'bold' },
    b = { fg = c.fg, bg = c.panel },
    c = { fg = c.muted, bg = 'NONE' },
  },
  insert   = { a = { fg = c.bg, bg = c.yellow, gui = 'bold' } },
  visual   = { a = { fg = c.bg, bg = c.green,  gui = 'bold' } },
  replace  = { a = { fg = c.bg, bg = c.err,    gui = 'bold' } },
  command  = { a = { fg = c.bg, bg = c.rose,   gui = 'bold' } },
  terminal = { a = { fg = c.bg, bg = c.green,  gui = 'bold' } },
  inactive = {
    a = { fg = c.dim, bg = 'NONE' },
    b = { fg = c.dim, bg = 'NONE' },
    c = { fg = c.dim, bg = 'NONE' },
  },
}
