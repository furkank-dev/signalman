-- lua/plugins/signalman-lualine.lua   (istege bagli)
--
-- Bu dosya renk temasi degil, YERLESIM duzeltmesi. LazyVim'in lualine
-- ayarlarini komple ezmez, sadece iki sorunu duzeltir:
--
--   1. `18:52` (satir:sutun) saat gibi okunuyordu. Yaninda gercek bir saat
--      varken bu ikisi ayirt edilemiyor. Konum artik "ln 18/393 · 52" olarak
--      yaziliyor, saat ise ayri bir renkte.
--   2. Powerline ok yonleri karisikti. Sag bolumde tum ayraclar sola bakar;
--      yon, okuma sirasini gosterir, dekorasyon degil.
--
-- Kurulum: dosyayi lua/plugins/ altina at, adi ne olursa olsun.

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local c = {
      accent = "#C57AD4",
      muted  = "#817E88",
      dim    = "#6A676F",
      gold   = "#87E496",
    }

    opts.options = opts.options or {}
    opts.options.theme = "signal-violet"

    -- Ayrac yonu: sol bolumde saga, sag bolumde sola. Tek yon = tek anlam.
    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "", right = "" }

    local s = opts.sections or {}

    -- Sag taraf yeniden kuruluyor: onceki hali dort ayri sayiyi ayni
    -- agirlikta gosteriyordu, hangisinin ne oldugu belli degildi.
    s.lualine_y = {
      {
        "progress",
        separator = " ",
        padding = { left = 1, right = 0 },
        color = { fg = c.dim },
      },
      {
        -- "ln 18/393 · 52" — saatle karistirilamaz.
        function()
          return string.format("ln %d/%d · %d", vim.fn.line("."), vim.fn.line("$"), vim.fn.col("."))
        end,
        padding = { left = 1, right = 1 },
        color = { fg = c.muted },
      },
    }

    s.lualine_z = {
      {
        function() return os.date("%H:%M") end,
        icon = "",
        color = { fg = "#000000", bg = c.gold, gui = "bold" },
      },
    }

    opts.sections = s
    return opts
  end,
}
