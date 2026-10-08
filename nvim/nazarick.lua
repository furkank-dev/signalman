-- nazarick.lua — Neovim colourscheme (Signalman ailesi, dorduncu palet)
--
-- Nazarick wallpaper'i ve "Mum Isigi" masaustu paletiyle birebir: anahtar
-- kelimeler, prompt ve mod rozeti masaustu altini (#E0B878). Kural: siyah
-- zemin, altin ana renk, tek soguk renk (celik). Dusuk doygunluk.
-- Terminal ANSI durust birakildi: yesil yesil, kirmizi kirmizi. git diff,
-- pytest, trivy ve semgrep bu ayrima bagli.
--
-- Olcumler (CIEDE2000 ayrim, APCA Lc kontrast, siyah zemin):
--   ana kod tokenlari arasinda en dusuk ayrim   dE 9.9
--   duz metin kontrasti                          Lc 74.5
--   yapisal tonlar (yorum/noktalama/cozulmemis) dE 6.6
--   uyari vs kod                                 dE 12.9
--   yorum kontrasti                              Lc 47
--
-- Kurulum:
--   lua/nazarick.lua                  (modul)
--   colors/nazarick.lua               (tek satir: require('nazarick').load())
--   lua/lualine/themes/nazarick.lua   (lualine)

local M = {}

-- Varsayilanlar. init.lua'dan degistirmek icin:
--   require('nazarick').setup({ transparent = false })
M.opts = {
  transparent = false,  -- yuzen pencereler, durum cubugu ve zemin saydam kalir
  cursorline  = true,   -- imlec satirinda cok hafif dolgu (L* +5.6, dikkat dagitmaz)
}

local c = {
  bg        = '#000000',
  bg_elev   = '#080503',
  bg_line   = '#110C08', -- imlec satiri: siyahin bir tik ustu, sicak
  bg_sel    = '#3C2A0E', -- secim: koyu altin
  border    = '#2A2319',

  fg        = '#D0C9C1', -- duz metin: sicak fildisi (en sik token en sakin olan)
  fg_bright = '#E9E4DC',

  -- kod ekseni: altin + krem + tek soguk renk (celik)
  keyword   = '#E0B878', -- def, if, return, import — masaustu altini
  func      = '#EADDBD', -- fonksiyonlar — soluk fildisi-krem, ekranin en parlak tokeni
  string    = '#90BDA4', -- soluk deniz yesili
  number    = '#E0A07D', -- sayilar, sabitler — bakir
  type      = '#BACDE1', -- tipler, siniflar, istisnalar — buz celigi
  builtin   = '#70A7C2', -- self, True/None, dekorator — celik mavisi
  param     = '#CDB0A9', -- parametreler (italik) — sicak gri-bej
  property  = '#9CB7B7', -- ozellikler, nesne anahtarlari — gri-camgobegi
  unknown   = '#96918C', -- LSP'nin cozemedigi isimler

  -- yapisal eksen
  comment   = '#A89688', -- Lc 47 — geride ama gunduz de okunur (italik)
  operator  = '#B1A9A2', -- operator anlam tasir, noktalamadan parlak
  punct     = '#877F76',
  linenr    = '#6E6860', -- gutter arayuzdur, kod degil

  -- regex govdesi ayri ele alinir
  regex      = '#6DA59D', -- literal karakterler (stringin soguk kardesi)
  regex_meta = '#A9E4E7', -- quantifier, anchor, karakter sinifi, kacis

  violet    = '#E0B878', -- chrome (adi tarihsel): arama, secim kenari, basliklar — altin
  warn      = '#F28F29', -- uyari: turuncu, bakirdan ayri (dE 12.9)
  clay      = '#FF7061', -- hatalar
  sage      = '#58BE6C', -- git added
  info      = '#78A1D5',
}

M.palette = c

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup(o)
  M.opts = vim.tbl_deep_extend('force', M.opts, o or {})
  M.load()
end

function M.load()
  local t = M.opts.transparent
  local NONE = 'NONE'
  local function bg(colour) return t and NONE or colour end
  local line_bg = M.opts.cursorline and not t and c.bg_line or NONE

  vim.cmd 'highlight clear'
  if vim.fn.exists('syntax_on') == 1 then vim.cmd 'syntax reset' end
  vim.o.background = 'dark'
  vim.o.termguicolors = true
  vim.g.colors_name = 'nazarick'

  -- ── editor ──────────────────────────────────────────────────────────
  hl('Normal',        { fg = c.fg, bg = bg(c.bg) })
  hl('NormalNC',      { fg = c.fg, bg = bg(c.bg) })
  hl('NormalFloat',   { fg = c.fg, bg = bg(c.bg_elev) })
  hl('FloatBorder',   { fg = t and '#443B32' or c.border, bg = bg(c.bg_elev) })
  hl('FloatTitle',    { fg = c.violet, bg = bg(c.bg_elev) })
  hl('Cursor',        { fg = c.bg, bg = c.func })
  hl('CursorLine',    { bg = line_bg })
  hl('CursorLineNr',  { fg = c.func, bold = true })
  hl('CursorLineSign',{ bg = line_bg })
  hl('CursorLineFold',{ bg = line_bg })
  hl('LineNr',        { fg = c.linenr })
  hl('LineNrAbove',   { fg = c.linenr })
  hl('LineNrBelow',   { fg = c.linenr })
  hl('SignColumn',    { bg = bg(c.bg) })
  hl('ColorColumn',   { bg = c.bg_elev })
  hl('Visual',        { bg = c.bg_sel })
  hl('Search',        { fg = c.bg, bg = c.violet })
  hl('IncSearch',     { fg = c.bg, bg = '#FFE9A8' })
  hl('CurSearch',     { fg = c.bg, bg = '#FFE9A8' })
  hl('MatchParen',    { fg = c.func, bold = true })
  hl('Whitespace',    { fg = '#2A2520' })
  hl('NonText',       { fg = '#2F2A25' })
  hl('VertSplit',     { fg = c.border })
  hl('WinSeparator',  { fg = c.border })
  hl('Folded',        { fg = c.comment, bg = bg(c.bg_elev) })
  hl('EndOfBuffer',   { fg = t and '#17130F' or c.bg, bg = bg(c.bg) })

  hl('StatusLine',    { fg = '#A39D97', bg = bg(c.bg_elev) })
  hl('StatusLineNC',  { fg = c.punct, bg = bg(c.bg) })
  hl('TabLine',       { fg = c.punct, bg = bg(c.bg) })
  hl('TabLineSel',    { fg = c.fg_bright, bg = c.bg_sel })
  hl('TabLineFill',   { bg = bg(c.bg) })
  hl('WinBar',        { fg = c.fg, bg = bg(c.bg) })
  hl('WinBarNC',      { fg = c.punct, bg = bg(c.bg) })

  hl('Pmenu',         { fg = c.fg, bg = bg(c.bg_elev) })
  hl('PmenuSel',      { fg = c.fg_bright, bg = c.bg_sel })
  hl('PmenuSbar',     { bg = bg(c.bg_elev) })
  hl('PmenuThumb',    { bg = c.border })
  hl('WildMenu',      { fg = c.fg_bright, bg = c.bg_sel })

  hl('Directory',     { fg = c.property })
  hl('Title',         { fg = c.violet, bold = true })
  hl('Question',      { fg = c.keyword })
  hl('MoreMsg',       { fg = c.keyword })
  hl('ErrorMsg',      { fg = c.clay })
  hl('WarningMsg',    { fg = c.warn })
  hl('ModeMsg',       { fg = c.fg })

  -- ── classic syntax groups ───────────────────────────────────────────
  hl('Comment',       { fg = c.comment, italic = true })
  hl('Keyword',       { fg = c.keyword })
  hl('Statement',     { fg = c.keyword })
  hl('Conditional',   { fg = c.keyword })
  hl('Repeat',        { fg = c.keyword })
  hl('Exception',     { fg = c.keyword })
  hl('Include',       { fg = c.keyword })
  hl('PreProc',       { fg = c.keyword })
  hl('Define',        { fg = c.keyword })
  hl('StorageClass',  { fg = c.keyword })
  hl('Structure',     { fg = c.keyword })
  hl('Operator',      { fg = c.operator })
  hl('Delimiter',     { fg = c.punct })
  hl('Function',      { fg = c.func })
  hl('Identifier',    { fg = c.fg })
  hl('String',        { fg = c.string })
  hl('Character',     { fg = c.string })
  hl('Number',        { fg = c.number })
  hl('Float',         { fg = c.number })
  hl('Boolean',       { fg = c.builtin })
  hl('Constant',      { fg = c.number })
  hl('Type',          { fg = c.type })
  hl('Typedef',       { fg = c.type })
  hl('Special',       { fg = c.func })
  hl('SpecialChar',   { fg = c.regex_meta })
  hl('Todo',          { fg = c.bg, bg = c.func, bold = true })
  hl('Error',         { fg = c.clay })
  hl('Underlined',    { fg = c.info, underline = true })

  -- ── treesitter ──────────────────────────────────────────────────────
  hl('@comment',              { link = 'Comment' })
  hl('@keyword',              { fg = c.keyword })
  hl('@keyword.function',     { fg = c.keyword })
  hl('@keyword.return',       { fg = c.keyword })
  hl('@keyword.operator',     { fg = c.keyword })
  hl('@keyword.import',       { fg = c.keyword })
  hl('@conditional',          { fg = c.keyword })
  hl('@repeat',               { fg = c.keyword })
  hl('@exception',            { fg = c.keyword })

  hl('@function',             { fg = c.func })
  hl('@function.call',        { fg = c.func })
  hl('@function.builtin',     { fg = c.func })
  hl('@function.method',      { fg = c.func })
  hl('@function.method.call', { fg = c.func })
  hl('@constructor',          { fg = c.type })

  hl('@string',               { fg = c.string })
  hl('@string.escape',        { fg = c.regex_meta })
  hl('@string.special',       { fg = c.regex_meta })
  hl('@character',            { fg = c.string })

  hl('@number',               { fg = c.number })
  hl('@float',                { fg = c.number })
  hl('@boolean',              { fg = c.builtin })
  hl('@constant',             { fg = c.number })
  hl('@constant.builtin',     { fg = c.builtin })
  hl('@constant.macro',       { fg = c.number })

  hl('@type',                 { fg = c.type })
  hl('@type.builtin',         { fg = c.type })
  hl('@type.definition',      { fg = c.type })
  hl('@attribute',            { fg = c.builtin })
  hl('@module',               { fg = c.property })
  hl('@namespace',            { fg = c.property })

  hl('@property',             { fg = c.property })
  hl('@field',                { fg = c.property })
  hl('@variable',             { fg = c.fg })
  hl('@variable.builtin',     { fg = c.builtin })
  hl('@variable.parameter',   { fg = c.param, italic = true })
  hl('@variable.member',      { fg = c.property })

  hl('@operator',             { fg = c.operator })
  hl('@punctuation',          { fg = c.punct })
  hl('@punctuation.bracket',  { fg = c.punct })
  hl('@punctuation.delimiter',{ fg = c.punct })
  hl('@punctuation.special',  { fg = c.func })

  hl('@tag',                  { fg = c.keyword })
  hl('@tag.attribute',        { fg = c.func })
  hl('@tag.delimiter',        { fg = c.punct })

  hl('@markup.heading',       { fg = c.violet, bold = true })
  hl('@markup.strong',        { fg = c.fg_bright, bold = true })
  hl('@markup.italic',        { fg = c.fg_bright, italic = true })
  hl('@markup.raw',           { fg = c.string })
  hl('@markup.link',          { fg = c.info, underline = true })
  hl('@markup.list',          { fg = c.func })
  hl('@markup.quote',         { fg = c.comment, italic = true })

  -- ── regex ───────────────────────────────────────────────────────────
  -- Neovim once `@capture.dil` adini dener; regex parser'i enjekte edildiginde
  -- asagidaki gruplar sadece regex govdesinde gecerli olur. Literal karakterler
  -- geri cekilir, metakarakterler one cikar — regex okurken goz quantifier ve
  -- anchor arar, harfleri degil.
  hl('@string.regexp',                   { fg = c.regex })
  hl('@string.regex',                    { fg = c.regex })
  hl('@character.regex',                 { fg = c.regex })
  hl('@constant.regex',                  { fg = c.regex })
  hl('@operator.regex',                  { fg = c.regex_meta })  -- * + ? | {n,m}
  hl('@punctuation.bracket.regex',       { fg = c.func })   -- ( ) [ ]
  hl('@punctuation.delimiter.regex',     { fg = c.func })
  hl('@punctuation.special.regex',       { fg = c.regex_meta })  -- ^ $ .
  hl('@character.special.regex',         { fg = c.regex_meta })
  hl('@constant.character.escape',       { fg = c.regex_meta })  -- \b \d \w \s
  hl('@constant.character.escape.regex', { fg = c.regex_meta })
  hl('@keyword.regex',                   { fg = c.keyword })
  hl('@variable.regex',                  { fg = c.property })   -- adlandirilmis grup
  hl('@property.regex',                  { fg = c.property })

  -- ── lsp semantic tokens ─────────────────────────────────────────────
  -- Anything the language server resolves gets a real colour here; anything
  -- it cannot resolve falls back to treesitter, which is why unresolved
  -- names read differently. Keep @lsp.type.variable pointing at plain fg.
  hl('@lsp.type.variable',      { fg = c.fg })
  hl('@lsp.type.parameter',     { fg = c.param, italic = true })
  hl('@lsp.type.property',      { fg = c.property })
  hl('@lsp.type.class',         { fg = c.type })
  hl('@lsp.type.interface',     { fg = c.type })
  hl('@lsp.type.enum',          { fg = c.type })
  hl('@lsp.type.enumMember',    { fg = c.number })
  hl('@lsp.type.function',      { fg = c.func })
  hl('@lsp.type.method',        { fg = c.func })
  hl('@lsp.type.namespace',     { fg = c.property })
  hl('@lsp.type.decorator',     { fg = c.builtin })
  hl('@lsp.type.selfKeyword',   { fg = c.builtin })
  hl('@lsp.type.regexp',        { fg = c.regex })
  hl('@lsp.mod.readonly',       { fg = c.number })

  -- ── diagnostics ─────────────────────────────────────────────────────
  -- Kehribar zeminde tehlike renkleri olculdu (CIEDE2000):
  --   hata vs fonksiyon 39.5 | hata vs sayi 23.9 | bilgi vs kod ekseni > 40
  -- Uyari kasten kehribar ailesinden: uyari kod degil, kodun bir hali.
  hl('DiagnosticError',         { fg = c.clay })
  hl('DiagnosticWarn',          { fg = c.warn })
  hl('DiagnosticInfo',          { fg = c.info })
  hl('DiagnosticHint',          { fg = c.type })
  hl('DiagnosticOk',            { fg = c.sage })
  hl('DiagnosticUnderlineError',{ sp = c.clay,      undercurl = true })
  hl('DiagnosticUnderlineWarn', { sp = c.warn, undercurl = true })
  hl('DiagnosticUnderlineInfo', { sp = c.info,      undercurl = true })
  hl('DiagnosticUnderlineHint', { sp = c.type,     undercurl = true })
  hl('DiagnosticUnnecessary',   { fg = c.unknown })

  hl('LspReferenceText',  { bg = c.bg_sel })
  hl('LspReferenceRead',  { bg = c.bg_sel })
  hl('LspReferenceWrite', { bg = '#1E1A22' })
  hl('LspInlayHint',      { fg = '#5C5751', bg = bg(c.bg_elev) })

  -- ── diff and git ────────────────────────────────────────────────────
  hl('DiffAdd',       { bg = '#0F1A0E' })
  hl('DiffChange',    { bg = '#141210' })
  hl('DiffDelete',    { fg = c.clay, bg = '#1A0F0C' })
  hl('DiffText',      { bg = '#2A2318' })
  hl('Added',         { fg = c.sage })
  hl('Changed',       { fg = c.warn })
  hl('Removed',       { fg = c.clay })

  hl('GitSignsAdd',    { fg = c.sage })
  hl('GitSignsChange', { fg = c.warn })
  hl('GitSignsDelete', { fg = c.clay })

  -- ── telescope ───────────────────────────────────────────────────────
  hl('TelescopeNormal',       { fg = c.fg, bg = bg(c.bg_elev) })
  hl('TelescopeBorder',       { fg = t and '#443B32' or c.border, bg = bg(c.bg_elev) })
  hl('TelescopeTitle',        { fg = c.violet })
  hl('TelescopePromptNormal', { fg = c.fg, bg = c.bg_sel })
  hl('TelescopePromptBorder', { fg = c.bg_sel, bg = c.bg_sel })
  hl('TelescopePromptTitle',  { fg = c.bg, bg = c.violet })
  hl('TelescopeSelection',    { fg = c.fg_bright, bg = c.bg_sel })
  hl('TelescopeMatching',     { fg = c.violet, bold = true })

  -- ── which-key, notify, misc plugins ─────────────────────────────────
  hl('WhichKey',          { fg = c.keyword })
  hl('WhichKeyGroup',     { fg = c.property })
  hl('WhichKeyDesc',      { fg = c.fg })
  hl('WhichKeySeparator', { fg = c.punct })
  hl('WhichKeyFloat',     { bg = bg(c.bg_elev) })

  hl('NvimTreeNormal',      { fg = c.fg, bg = bg(c.bg) })
  hl('NvimTreeFolderName',  { fg = c.property })
  hl('NvimTreeOpenedFolderName', { fg = c.fg_bright })
  hl('NvimTreeRootFolder',  { fg = c.violet })
  hl('NvimTreeGitDirty',    { fg = c.func })
  hl('NvimTreeGitNew',      { fg = c.sage })

  -- indent guides — LazyVim uses snacks.indent; indent-blankline names are
  -- kept as a fallback. Raised well above the theme's other structural marks
  -- because indentation carries meaning in Python and YAML.
  hl('SnacksIndent',       { fg = '#26211A' })
  hl('SnacksIndentScope',  { fg = '#554F48' })
  hl('SnacksIndentChunk',  { fg = '#554F48' })
  hl('SnacksIndentBlank',  { fg = '#2A2520' })
  hl('IblIndent',          { fg = '#26211A' })
  hl('IblScope',           { fg = '#554F48' })
  hl('IndentBlanklineChar',      { fg = '#37322C' })
  hl('IndentBlanklineContextChar', { fg = '#69625B' })

  -- ── diagnostic virtual lines ────────────────────────────────────────
  -- options.lua'da virtual_lines aciktir, bu gruplara gun boyu bakilir
  hl('DiagnosticVirtualLinesError', { fg = c.clay,      bg = '#170A08' })
  hl('DiagnosticVirtualLinesWarn',  { fg = c.warn,      bg = '#161006' })
  hl('DiagnosticVirtualLinesInfo',  { fg = c.info,      bg = '#0A0D13' })
  hl('DiagnosticVirtualLinesHint',  { fg = c.property, bg = c.bg_elev })
  hl('DiagnosticVirtualTextError',  { fg = c.clay })
  hl('DiagnosticVirtualTextWarn',   { fg = c.warn })
  hl('DiagnosticVirtualTextInfo',   { fg = c.info })
  hl('DiagnosticVirtualTextHint',   { fg = c.property })
  hl('DiagnosticDeprecated',        { fg = c.unknown, strikethrough = true })

  -- ── snacks.picker (LazyVim artik Telescope yerine bunu kullaniyor) ──
  hl('SnacksPickerBorder',    { fg = c.border,    bg = c.bg_elev })
  hl('SnacksPickerTitle',     { fg = c.violet })
  hl('SnacksPickerInput',     { fg = c.fg,        bg = c.bg_sel })
  hl('SnacksPickerInputTitle',{ fg = c.bg,        bg = c.violet })
  hl('SnacksPickerList',      { fg = c.fg,        bg = c.bg_elev })
  hl('SnacksPickerListTitle', { fg = c.violet })
  hl('SnacksPickerMatch',     { fg = c.violet,    bold = true })
  hl('SnacksPickerSelected',  { fg = c.fg_bright, bg = c.bg_sel })
  hl('SnacksPickerDir',       { fg = c.operator })
  hl('SnacksPickerFile',      { fg = c.fg })
  hl('SnacksPickerPreview',   { bg = c.bg })

  -- ── blink.cmp ──────────────────────────────────────────────────────
  hl('BlinkCmpMenu',            { fg = c.fg,        bg = c.bg_elev })
  hl('BlinkCmpMenuBorder',      { fg = c.border,    bg = c.bg_elev })
  hl('BlinkCmpMenuSelection',   { fg = c.fg_bright, bg = c.bg_sel })
  hl('BlinkCmpLabel',           { fg = c.fg })
  hl('BlinkCmpLabelMatch',      { fg = c.violet,    bold = true })
  hl('BlinkCmpLabelDeprecated', { fg = c.unknown,   strikethrough = true })
  hl('BlinkCmpKind',            { fg = c.keyword })
  hl('BlinkCmpKindFunction',    { fg = c.func })
  hl('BlinkCmpKindMethod',      { fg = c.func })
  hl('BlinkCmpKindVariable',    { fg = c.fg })
  hl('BlinkCmpKindClass',       { fg = c.type })
  hl('BlinkCmpKindKeyword',     { fg = c.keyword })
  hl('BlinkCmpKindText',        { fg = c.fg })
  hl('BlinkCmpKindSnippet',     { fg = c.violet })
  hl('BlinkCmpDoc',             { fg = c.fg,     bg = c.bg_elev })
  hl('BlinkCmpDocBorder',       { fg = c.border, bg = c.bg_elev })
  hl('BlinkCmpSignatureHelp',   { fg = c.fg,     bg = c.bg_elev })
  hl('BlinkCmpSignatureHelpActiveParameter', { fg = c.violet, bold = true })

  -- ── temel eksikler ──────────────────────────────────────────────────
  hl('CursorColumn',  { bg = c.bg_line })
  hl('Substitute',    { fg = c.bg, bg = c.func })
  hl('QuickFixLine',  { fg = c.fg_bright, bg = c.bg_sel })
  hl('Conceal',       { fg = c.punct })
  hl('MsgArea',       { fg = c.fg })
  hl('MsgSeparator',  { fg = c.border })
  hl('LspCodeLens',   { fg = c.operator })
  hl('LspSignatureActiveParameter', { fg = c.violet, bold = true })

  hl('SpellBad',   { sp = c.clay,      undercurl = true })
  hl('SpellCap',   { sp = c.warn,      undercurl = true })
  hl('SpellLocal', { sp = c.info,      undercurl = true })
  hl('SpellRare',  { sp = c.property, undercurl = true })

  -- ── treesitter tamamlayicilar ───────────────────────────────────────
  hl('@comment.todo',    { fg = c.bg, bg = c.func, bold = true })
  hl('@comment.note',    { fg = c.bg, bg = c.info,      bold = true })
  hl('@comment.warning', { fg = c.bg, bg = c.warn,      bold = true })
  hl('@comment.error',   { fg = c.bg, bg = c.clay,      bold = true })
  hl('@diff.plus',       { fg = c.sage })
  hl('@diff.minus',      { fg = c.clay })
  hl('@diff.delta',      { fg = c.func })
  hl('@string.documentation',       { fg = c.string })
  hl('@variable.parameter.builtin', { fg = c.builtin })
  hl('@markup.heading.1', { fg = c.violet,    bold = true })
  hl('@markup.heading.2', { fg = c.type,     bold = true })
  hl('@markup.heading.3', { fg = c.func, bold = true })
  hl('@markup.heading.4', { fg = c.keyword })
  hl('@markup.heading.5', { fg = c.property })
  hl('@markup.heading.6', { fg = c.operator })

  -- ── flash.nvim ──────────────────────────────────────────────────────
  -- Atlama etiketleri chrome ailesinden: navigasyon arayuzdur, kod degil.
  -- Etiket en belirgin olan; eslesme bir ton geride, arka plan sonuk.
  hl('FlashBackdrop',   { fg = c.linenr })
  hl('FlashMatch',      { fg = c.bg, bg = c.property })
  hl('FlashCurrent',    { fg = c.bg, bg = c.func })
  hl('FlashLabel',      { fg = c.bg, bg = c.violet, bold = true })
  hl('FlashPrompt',     { fg = c.fg, bg = c.bg_elev })
  hl('FlashPromptIcon', { fg = c.violet })
  hl('FlashCursor',     { fg = c.bg, bg = c.violet })


  -- ── terminal palette, matching the kitty config ─────────────────────
  vim.g.terminal_color_0  = '#3E4348'
  vim.g.terminal_color_1  = '#FF7061'
  vim.g.terminal_color_2  = '#58BE6C'
  vim.g.terminal_color_3  = '#F7BD00'
  vim.g.terminal_color_4  = '#78A1D5'
  vim.g.terminal_color_5  = '#CF8FDD'
  vim.g.terminal_color_6  = '#70BCC5'
  vim.g.terminal_color_7  = '#D0C9C1'
  vim.g.terminal_color_8  = '#86898C'
  vim.g.terminal_color_9  = '#F6A397'
  vim.g.terminal_color_10 = '#6BD47F'
  vim.g.terminal_color_11 = '#FFD87A'
  vim.g.terminal_color_12 = '#99B7DC'
  vim.g.terminal_color_13 = '#DBB0E5'
  vim.g.terminal_color_14 = '#85D2DB'
  vim.g.terminal_color_15 = '#E9E4DC'
end

-- :NazarickCheck — token gruplarinin cozulmus renklerini ve siyah zemine gore
-- APCA kontrastini yazar. Tema degistirdiginde "acaba tanimli mi" diye
-- tahmin etmemek icin.
vim.api.nvim_create_user_command('NazarickCheck', function()
  local groups = {
    'Normal', 'Comment', 'Keyword', 'Function', 'String', 'Number', 'Type',
    '@property', '@variable.parameter', '@variable.builtin', '@operator', '@punctuation.bracket',
    '@string.regexp', '@constant.character.escape', 'LineNr', 'CursorLineNr',
    'DiagnosticError', 'DiagnosticWarn', 'DiagnosticInfo', 'DiagnosticHint',
  }
  local function lc(hex)
    local r = tonumber(hex:sub(2, 3), 16) / 255
    local g = tonumber(hex:sub(4, 5), 16) / 255
    local b = tonumber(hex:sub(6, 7), 16) / 255
    local y = 0.2126729 * r ^ 2.4 + 0.7151522 * g ^ 2.4 + 0.0721750 * b ^ 2.4
    y = y > 0.022 and y or y + (0.022 - y) ^ 1.414
    local s = (0.022 ^ 0.56 - y ^ 0.57) * 1.14
    return math.abs(s < 0 and s + 0.027 or s - 0.027) * 100
  end
  local lines = { 'group                          renk       APCA Lc', '' }
  for _, g in ipairs(groups) do
    local h = vim.api.nvim_get_hl(0, { name = g, link = false })
    if h and h.fg then
      local hex = string.format('#%06X', h.fg)
      lines[#lines + 1] = string.format('%-30s %-10s %5.1f', g, hex, lc(hex))
    else
      lines[#lines + 1] = string.format('%-30s %s', g, 'TANIMSIZ')
    end
  end
  lines[#lines + 1] = ''
  lines[#lines + 1] = 'Lc 45+ okunabilir, 60+ govde metni, 30 alti sadece dekor.'
  vim.cmd 'new'
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end, { desc = 'Nazarick: token renkleri ve kontrast raporu' })

M.load()
return M
