-- lua/lualine/themes/signal-violet.lua
--
-- Mod rengi = masaustunun iki rengi: normal mor, insert sari. Diger modlar
-- kod ekseninden birer ton alir ki hangi modda oldugun ilk bakista okunsun.
-- b/c bolumleri notr: durum cubugu kod degil, arayuz.
local c = {
  bg      = '#000000',
  panel   = '#060509',
  fg      = '#DFDDE4',
  muted   = '#817E88',
  dim     = '#6A676F',
  accent  = '#C57AD4',
  yellow  = '#F5C842',
  green   = '#87E496',
  rose    = '#EB9DBB',
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
