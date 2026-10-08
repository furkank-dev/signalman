#!/usr/bin/env python3
"""
build.py — bir palet dosyasindan temanin butun dosyalarini uretir.

    python3 tools/build.py tools/palettes/signal-violet.toml

Uretilenler (slug = paletteki `slug`):
    nvim/<slug>.lua                    Neovim colourscheme + :<Ad>Check
    nvim/<slug>-lualine.lua            lualine temasi
    nvim/<slug>-lualine-sections.lua   lualine yerlesim duzeltmesi (istege bagli)
    terminal/<slug>.conf               kitty
    terminal/<slug>-shell.sh           prompt, ls, grep, man, jq, bat, fzf
    terminal/<slug>.tmTheme            bat / delta
    themes/<slug>-color-theme.json     VSCodium
    yazi/<slug>.yazi/                  Yazi flavor (arayuz + kod onizlemesi)

Nasil calisir: Guardian (nvim/guardian.lua vb.) kalip olarak kullanilir.
Guardian'in her rengi bir role karsilik gelir (HEX_ROLES); o renkler
paletteki karsiliklariyla degistirilir, sonra Guardian'in birlestirdigi
roller (self/True/dekorator, parametre, uyari) ayrilir. Guardian'a eklenen
her duzeltme (yeni eklenti grubu vb.) boylece bir sonraki uretimde yeni
temaya da gecer.

ANSI 16 renk bilerek degistirilmez: git diff, pytest, trivy kirmizi/yesile
dayanir. Sadece duz metin (color7/color15) paletten gelir.

Tema package.json'da kayitli degilse otomatik eklenir. Surum numarasi ve
CHANGELOG girdisi elle (bkz. tools/README.md).
"""
import html
import json
import os
import re
import sys
import tomllib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from colorlib import oklch_to_hex, resolve, rgb_triplet  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/'

# Guardian'daki her renk -> palette rolu. Rol yerine (L, C) verilenler
# notr arayuz tonlaridir; paletin `neutral_hue` tintiyle uretilir.
HEX_ROLES = {
    '#08090A': 'bg_elev', '#101214': 'bg_line', '#24202E': 'bg_sel', '#1E2226': 'border',
    '#C6CACD': 'fg', '#E8ECEF': 'fg_bright',
    '#A7B2BD': 'keyword', '#F7C371': 'function', '#B4BDC4': 'string', '#C4A86D': 'number',
    '#DFE6EC': 'type', '#8E9DAA': 'property', '#7E8B92': 'param', '#86898C': 'unknown',
    '#8D998F': 'comment', '#A1A6AB': 'operator', '#757D84': 'punct', '#6F7275': 'linenr',
    '#A89C93': 'regex', '#DCC58C': 'regex_meta', '#F7BD00': 'warn',
    '#C57AD4': 'violet',   # Guardian'in chrome moru (secim, link, isaret); Signal Violet'te ayni renk oldugu icin fark edilmemisti
    # notr / sicak artiklar (vurgu katmanlari, girinti cizgileri, bosluk isaretleri)
    '#D6DCE1': (0.88, 0.010), '#6C7075': (0.55, 0.012), '#5C6165': (0.49, 0.012),
    '#101418': (0.17, 0.012), '#4E5661': (0.43, 0.014), '#0A0C0D': (0.11, 0.008),
    '#232830': (0.25, 0.014), '#4A4238': (0.36, 0.020), '#2C261C': (0.27, 0.012),
    '#332C22': (0.29, 0.012), '#1A1712': (0.19, 0.010), '#9F9A8F': (0.70, 0.012),
    '#5A554C': (0.46, 0.012), '#3A342A': (0.32, 0.012), '#6A6052': (0.50, 0.014),
}

ROLES = ['bg', 'bg_elev', 'bg_line', 'bg_sel', 'border', 'fg', 'fg_bright', 'keyword', 'function',
         'string', 'number', 'type', 'builtin', 'param', 'property', 'unknown', 'comment', 'operator',
         'punct', 'linenr', 'regex', 'regex_meta', 'violet', 'warn', 'clay', 'sage', 'info']


def load(path):
    with open(path, 'rb') as f:
        cfg = tomllib.load(f)
    P = {k: resolve(v) for k, v in cfg['colors'].items()}
    missing = [r for r in ROLES if r not in P]
    if missing:
        sys.exit(f'palette eksik roller: {missing}')
    return cfg, P


def read(rel):
    with open(ROOT + rel, encoding='utf-8') as f:
        return f.read()


def write(rel, text):
    os.makedirs(os.path.dirname(ROOT + rel), exist_ok=True)
    with open(ROOT + rel, 'w', encoding='utf-8') as f:
        f.write(text)
    print('  yazildi:', rel)


def build(cfg, P):
    name, slug, prefix = cfg['name'], cfg['slug'], cfg['shell_prefix']
    T = cfg['text']
    hue = cfg.get('neutral_hue', 300)
    camel = name.replace(' ', '')
    fn = slug.replace('-', '_')

    HEX = {g: (P[r] if isinstance(r, str) else oklch_to_hex(r[0], r[1], hue)) for g, r in HEX_ROLES.items()}

    def maphex(s, skip=lambda line: False):
        out = []
        for line in s.splitlines(keepends=True):
            if not skip(line):
                for a, b in HEX.items():
                    line = re.sub(re.escape(a), b, line, flags=re.I)
            out.append(line)
        return ''.join(out)

    def fill(template):
        return re.sub(r'@@(\w+)@@', lambda m: P[m.group(1)], template)

    # ── 1. Neovim ───────────────────────────────────────────────────
    src = read('nvim/guardian.lua')
    head_end = src.index('local M = {}')
    pal_start, pal_end = src.index('local c = {'), src.index('M.palette = c')
    body = src[head_end:pal_start] + '@@PALETTE@@\n\n' + src[pal_end:]
    body = maphex(body, skip=lambda l: 'terminal_color_' in l and not ('color_7 ' in l or 'color_15' in l))
    for a, b in [('c.gold_pale', 'c.func'), ('c.gold_mid', 'c.string'), ('c.gold', 'c.keyword'),
                 ('c.cream', 'c.number'), ('c.steel_dim', 'c.property'), ('c.steel', 'c.type'),
                 ('c.armour', 'c.param')]:
        body = body.replace(a, b)
    body = body.replace("'guardian'", f"'{slug}'").replace("require('guardian')", f"require('{slug}')")

    def setl(group, val):
        nonlocal body
        pat = re.compile(r"(hl\('" + re.escape(group) + r"',\s*)\{[^}]*\}\)")
        assert pat.search(body), group
        body = pat.sub(lambda m: m.group(1) + val + ')', body, count=1)

    # Guardian'in birlestirdigi rolleri ayir
    for g in ['@variable.builtin', '@constant.builtin', '@boolean', '@attribute', '@variable.parameter.builtin',
              'Boolean', '@lsp.type.selfKeyword', '@lsp.type.decorator']:
        setl(g, '{ fg = c.builtin }')
    setl('@keyword.operator', '{ fg = c.keyword }')
    setl('Comment', '{ fg = c.comment, italic = true }')
    setl('@variable.parameter', '{ fg = c.param, italic = true }')
    setl('@lsp.type.parameter', '{ fg = c.param, italic = true }')
    setl('@comment.warning', '{ fg = c.bg, bg = c.warn,      bold = true }')
    setl('DiagnosticUnderlineWarn', '{ sp = c.warn, undercurl = true }')
    setl('DiagnosticVirtualTextWarn', '{ fg = c.warn }')
    setl('DiagnosticVirtualLinesWarn', "{ fg = c.warn,      bg = '#161006' }")
    setl('WarningMsg', '{ fg = c.warn }')
    setl('SpellCap', '{ sp = c.warn,      undercurl = true }')

    body = body.replace('@@PALETTE@@', fill(T['nvim_palette'].strip('\n')))
    body = body.replace("vim.api.nvim_create_user_command('GuardianCheck'",
                        f"vim.api.nvim_create_user_command('{camel}Check'")
    body = body.replace('-- :SignalmanCheck —', f'-- :{camel}Check —')
    body = body.replace("desc = 'Signalman: token renkleri ve kontrast raporu'",
                        f"desc = '{name}: token renkleri ve kontrast raporu'")
    body = body.replace("'@property', '@variable.parameter', '@operator',",
                        "'@property', '@variable.parameter', '@variable.builtin', '@operator',")
    body = body.replace("--   require('guardian').setup({ transparent = false })",
                        f"--   require('{slug}').setup({{ transparent = false }})")
    write(f'nvim/{slug}.lua', T['nvim_header'].lstrip('\n') + '\n' + body)

    # ── 2. lualine ──────────────────────────────────────────────────
    lu = (f'-- lua/lualine/themes/{slug}.lua\n--\n' + T['lualine_header'].lstrip('\n') + fill('''local c = {
  bg      = '#000000',
  panel   = '@@bg_elev@@',
  fg      = '@@fg@@',
  muted   = '@@punct@@',
  dim     = '@@linenr@@',
  accent  = '@@violet@@',
  yellow  = '@@function@@',
  green   = '@@string@@',
  rose    = '@@builtin@@',
  err     = '@@clay@@',
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
'''))
    write(f'nvim/{slug}-lualine.lua', lu)
    sec = maphex(read('nvim/guardian-lualine-sections.lua')).replace('"guardian"', f'"{slug}"').replace('guardian', slug)
    write(f'nvim/{slug}-lualine-sections.lua', sec)

    # ── 3. kitty ────────────────────────────────────────────────────
    kc = maphex(read('terminal/guardian.conf'),
                skip=lambda l: re.match(r'color(\d+)\s', l) and l.split()[0] not in ('color7', 'color15'))
    kc = re.sub(r'#  GUARDIAN\n(#.*\n)*?(?=# ═)',
                lambda m: f'#  {name.upper()}\n#\n' + T['kitty_header'].lstrip('\n'), kc)
    kc = kc.replace('terminal/guardian-shell.sh', f'terminal/{slug}-shell.sh')
    kc = kc.replace('Editor kehribar, terminal beyaz', 'Editor renkli, terminal beyaz')
    write(f'terminal/{slug}.conf', kc)

    # ── 4. kabuk ────────────────────────────────────────────────────
    sh = read('terminal/guardian-shell.sh')
    shell_vars = {
        '__gd_violet': ('violet', 'chrome'), '__gd_gold': ('keyword', 'keyword'),
        '__gd_gold_pale': ('function', 'function'), '__gd_gold_mid': ('string', 'string'),
        '__gd_cream': ('number', 'number'), '__gd_steel': ('type', 'type'),
        '__gd_steel_dim': ('property', 'property'), '__gd_fg': ('fg', 'text'),
        '__gd_punct': ('punct', 'punctuation'), '__gd_dim': ('linenr', 'gutter'),
        '__gd_clay': ('clay', 'error'), '__gd_sage': ('sage', 'ok'),
    }
    for var, (role, label) in shell_vars.items():
        sh = re.sub(r'^' + var + r"='[^']*'\s*#.*$",
                    lambda m: f"{var}='{rgb_triplet(P[role])}'  # {P[role]}  {label}", sh, flags=re.M)
    sh = sh.replace('__gd_', f'__{prefix}_').replace('__guardian_', f'__{fn}_')
    sh = sh.replace('GUARDIAN — kabuk tarafi', f'{name.upper()} — kabuk tarafi')
    sh = sh.replace('guardian-shell.sh', f'{slug}-shell.sh')
    sh = sh.replace('# nvim/signalman.lua ve terminal/signalman.conf ile ayni degerler.',
                    f'# nvim/{slug}.lua ve terminal/{slug}.conf ile ayni degerler.')
    sh = sh.replace('Editor kehribar, terminal duz beyazsa', 'Editor renkli, terminal duz beyazsa')
    old_bat = ('# ── bat / delta ────────────────────────────────────────────────────\n'
               "# bat'in kendi temasi yok; en yakini ANSI'ye saygi duyani.\n"
               'export BAT_THEME="ansi"\n')
    new_bat = f'''# ── bat / delta ────────────────────────────────────────────────────
# terminal/{slug}.tmTheme, bat'in tema klasorune kopyalanip
# `bat cache --build` calistirildiysa onu kullan; yoksa ANSI'ye dus.
# bat temayi dosya adindan tanir. delta da BAT_THEME'i okur.
if [ -f "${{XDG_CONFIG_HOME:-$HOME/.config}}/bat/themes/{slug}.tmTheme" ]; then
  export BAT_THEME="{slug}"
else
  export BAT_THEME="ansi"
fi

# ── fzf ────────────────────────────────────────────────────────────
# Eslesme mor, secili satir koyu mor zemin + sari isaretci.
# Kabuk dosyasi tekrar source edilirse ayni renk iki kez eklenmesin.
case "${{FZF_DEFAULT_OPTS:-}}" in
  *"hl:{P['violet']}"*) ;;
  *) export FZF_DEFAULT_OPTS="${{FZF_DEFAULT_OPTS:-}} --color=fg:{P['fg']},bg:-1,hl:{P['violet']},fg+:{P['fg_bright']},bg+:{P['bg_sel']},hl+:{P['function']},info:{P['punct']},prompt:{P['violet']},pointer:{P['function']},marker:{P['string']},spinner:{P['violet']},header:{P['comment']},border:{P['border']},gutter:-1" ;;
esac
'''
    assert old_bat in sh, 'guardian-shell.sh bat blogu degismis; build.py guncellenmeli'
    sh = sh.replace(old_bat, new_bat)
    sh = sh.replace('ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737068"', f'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg={P["linenr"]}"')
    assert 'guardian' not in sh.lower(), [l for l in sh.splitlines() if 'guardian' in l.lower()][:5]
    write(f'terminal/{slug}-shell.sh', sh)

    # ── 5. VSCodium ─────────────────────────────────────────────────
    d = json.loads(read('themes/guardian-color-theme.json'))
    d['name'] = name

    def mapv(v):
        if isinstance(v, str) and v.startswith('#'):
            return HEX.get(v[:7].upper(), v[:7]) + v[7:]
        return v
    for k, v in list(d['colors'].items()):
        if k.startswith('terminal.ansi') and k not in ('terminal.ansiWhite', 'terminal.ansiBrightWhite'):
            continue
        d['colors'][k] = mapv(v)
    for t in d['tokenColors']:
        for kk in ('foreground', 'background'):
            if kk in t['settings']:
                t['settings'][kk] = mapv(t['settings'][kk])
    for k, v in d['semanticTokenColors'].items():
        if isinstance(v, str):
            d['semanticTokenColors'][k] = mapv(v)
        elif isinstance(v, dict) and 'foreground' in v:
            v['foreground'] = mapv(v['foreground'])
    d['semanticTokenColors'].update({
        'decorator': P['builtin'], 'macro': P['builtin'], 'selfKeyword': P['builtin'],
        'variable.defaultLibrary': P['builtin'], 'typeParameter': P['type'],
        'parameter': {'foreground': P['param'], 'fontStyle': 'italic'}})
    for t in d['tokenColors']:
        n = t.get('name', '')
        if n.startswith('Language constants'):
            t['settings']['foreground'] = P['builtin']
            t['scope'] = list(t['scope']) + ['variable.language', 'variable.language.self',
                                             'variable.language.special.self',
                                             'variable.parameter.function.language.special.self']
        if n.startswith('Namespaces, modules, decorators'):
            deco = [x for x in t['scope'] if 'decorator' in x]
            t['scope'] = [x for x in t['scope'] if 'decorator' not in x]
            t['name'] = 'Namespaces, modules'
            d['tokenColors'].append({'name': 'Decorators', 'scope': deco + [
                'punctuation.definition.decorator', 'entity.name.function.decorator', 'meta.annotation',
                'variable.annotation', 'punctuation.definition.annotation'],
                'settings': {'foreground': P['builtin']}})
        if n == 'Function parameters':
            t['settings']['fontStyle'] = 'italic'
    d['tokenColors'].append({'name': 'Word operators (and, or, not, in, is)', 'scope': [
        'keyword.operator.logical.python', 'keyword.operator.word', 'keyword.operator.expression',
        'keyword.operator.new'], 'settings': {'foreground': P['keyword']}})
    write(f'themes/{slug}-color-theme.json', json.dumps(d, indent=2, ensure_ascii=False) + '\n')

    # ── 6. tmTheme (bat, delta, Yazi onizlemesi) ────────────────────
    def kv(k, v):
        return f'\t\t\t\t<key>{k}</key>\n\t\t\t\t<string>{html.escape(v)}</string>\n'
    glob = {'background': P['bg'], 'foreground': P['fg'], 'caret': P['function'], 'selection': P['bg_sel'],
            'lineHighlight': P['bg_line'], 'invisibles': P['punct'], 'gutterForeground': P['linenr'],
            'findHighlight': P['violet'], 'findHighlightForeground': '#000000'}
    items = ['\t\t<dict>\n\t\t\t<key>settings</key>\n\t\t\t<dict>\n'
             + ''.join(kv(k, v) for k, v in glob.items()) + '\t\t\t</dict>\n\t\t</dict>\n']
    for t in d['tokenColors']:
        sc = t['scope']
        sc = ', '.join(sc) if isinstance(sc, list) else sc
        s = {k: v for k, v in t['settings'].items() if k in ('foreground', 'background', 'fontStyle')}
        if not s:
            continue
        items.append('\t\t<dict>\n'
                     + f'\t\t\t<key>name</key>\n\t\t\t<string>{html.escape(t.get("name", ""))}</string>\n'
                     + f'\t\t\t<key>scope</key>\n\t\t\t<string>{html.escape(sc)}</string>\n'
                     + '\t\t\t<key>settings</key>\n\t\t\t<dict>\n'
                     + ''.join(kv(k, v) for k, v in s.items()) + '\t\t\t</dict>\n\t\t</dict>\n')
    tm = ('<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          f'<plist version="1.0">\n<dict>\n\t<key>name</key>\n\t<string>{html.escape(name)}</string>\n'
          f'\t<key>comment</key>\n\t<string>{html.escape(T["tmtheme_comment"])}</string>\n'
          '\t<key>settings</key>\n\t<array>\n' + ''.join(items) + '\t</array>\n</dict>\n</plist>\n')
    write(f'terminal/{slug}.tmTheme', tm)

    # ── 7. Yazi flavor ──────────────────────────────────────────────
    y = f'yazi/{slug}.yazi/'
    write(y + 'flavor.toml', f'# {name} — Yazi flavor\n#\n' + T['yazi_header'].lstrip('\n') + fill(YAZI_BODY))
    write(y + 'tmtheme.xml', tm)
    lic = read('LICENSE')
    write(y + 'LICENSE', lic)
    write(y + 'LICENSE-tmtheme', lic)
    write(y + 'README.md', f'# {name} — Yazi flavor\n\n' + T['yazi_readme_intro'].lstrip('\n') + f'''
## Kurulum

```sh
cp -r yazi/{slug}.yazi ~/.config/yazi/flavors/
```

`~/.config/yazi/theme.toml`:

```toml
[flavor]
dark = "{slug}"
```
''')

    # ── package.json: tema kayitli degilse ekle ─────────────────────
    pkg = json.loads(read('package.json'))
    themes = pkg['contributes']['themes']
    path = f'./themes/{slug}-color-theme.json'
    if not any(t['path'] == path for t in themes):
        themes.append({'label': name, 'uiTheme': 'vs-dark', 'path': path})
        write('package.json', json.dumps(pkg, indent=2, ensure_ascii=False) + '\n')

    # ── kontrol: Guardian'dan kalan renk var mi? ────────────────────
    left = []
    for rel in [f'nvim/{slug}.lua', f'terminal/{slug}.conf', f'themes/{slug}-color-theme.json',
                f'nvim/{slug}-lualine-sections.lua']:
        for line in read(rel).splitlines():
            if 'terminal_color' in line or re.match(r'\s*color\d+\s', line) or 'terminal.ansi' in line:
                continue
            left += [(rel, h) for h in HEX if h.lower() in line.lower()]
    print('  Guardian renginden kalan:', sorted(set(left)) or 'yok')


YAZI_BODY = '''
[mgr]
cwd              = { fg = "@@violet@@", bold = true }
find_keyword     = { fg = "@@function@@", bold = true, underline = true }
find_position    = { fg = "@@builtin@@", bg = "reset", bold = true }
symlink_target   = { fg = "@@property@@", italic = true }
marker_copied    = { fg = "@@string@@", bg = "@@string@@" }
marker_cut       = { fg = "@@clay@@", bg = "@@clay@@" }
marker_marked    = { fg = "@@violet@@", bg = "@@violet@@" }
marker_selected  = { fg = "@@function@@", bg = "@@function@@" }
count_copied     = { fg = "@@bg@@", bg = "@@string@@" }
count_cut        = { fg = "@@bg@@", bg = "@@clay@@" }
count_selected   = { fg = "@@bg@@", bg = "@@function@@" }
border_symbol    = "│"
border_style     = { fg = "@@border@@" }

[indicator]
parent  = { fg = "@@fg_bright@@", bg = "@@bg_sel@@" }
current = { fg = "@@bg@@", bg = "@@violet@@", bold = true }
preview = { underline = true }

[tabs]
active   = { fg = "@@bg@@", bg = "@@function@@", bold = true }
inactive = { fg = "@@punct@@", bg = "@@bg_elev@@" }

[mode]
normal_main = { fg = "@@bg@@", bg = "@@violet@@", bold = true }
normal_alt  = { fg = "@@violet@@", bg = "@@bg_elev@@" }
select_main = { fg = "@@bg@@", bg = "@@string@@", bold = true }
select_alt  = { fg = "@@string@@", bg = "@@bg_elev@@" }
unset_main  = { fg = "@@bg@@", bg = "@@builtin@@", bold = true }
unset_alt   = { fg = "@@builtin@@", bg = "@@bg_elev@@" }

[status]
perm_type       = { fg = "@@property@@" }
perm_read       = { fg = "@@function@@" }
perm_write      = { fg = "@@clay@@" }
perm_exec       = { fg = "@@string@@" }
perm_sep        = { fg = "@@linenr@@" }
progress_label  = { fg = "@@fg_bright@@", bold = true }
progress_normal = { fg = "@@violet@@", bg = "@@bg_elev@@" }
progress_error  = { fg = "@@clay@@", bg = "@@bg_elev@@" }

[which]
mask            = { bg = "@@bg_elev@@" }
cand            = { fg = "@@function@@" }
rest            = { fg = "@@punct@@" }
desc            = { fg = "@@fg@@" }
separator       = "  "
separator_style = { fg = "@@linenr@@" }

[confirm]
border  = { fg = "@@violet@@" }
title   = { fg = "@@violet@@", bold = true }
body    = { fg = "@@fg@@" }
list    = { fg = "@@operator@@" }
btn_yes = { fg = "@@bg@@", bg = "@@function@@", bold = true }
btn_no  = { fg = "@@fg@@", bg = "@@bg_elev@@" }

[spot]
border   = { fg = "@@violet@@" }
title    = { fg = "@@violet@@", bold = true }
tbl_col  = { fg = "@@property@@" }
tbl_cell = { fg = "@@fg@@" }

[notify]
title_info  = { fg = "@@info@@" }
title_warn  = { fg = "@@warn@@" }
title_error = { fg = "@@clay@@" }

[pick]
border   = { fg = "@@violet@@" }
active   = { fg = "@@violet@@", bold = true }
inactive = { fg = "@@fg@@" }

[input]
border   = { fg = "@@violet@@" }
title    = { fg = "@@violet@@" }
value    = { fg = "@@fg_bright@@" }
selected = { bg = "@@bg_sel@@" }

[cmp]
border   = { fg = "@@violet@@" }
active   = { fg = "@@bg@@", bg = "@@violet@@" }
inactive = { fg = "@@fg@@" }

[tasks]
border  = { fg = "@@violet@@" }
title   = { fg = "@@violet@@" }
hovered = { fg = "@@function@@", underline = true }

[help]
border  = { fg = "@@violet@@" }
chord   = { fg = "@@function@@" }
action  = { fg = "@@string@@" }
hovered = { bg = "@@bg_sel@@", bold = true }

[filetype]
rules = [
  { mime = "image/*", fg = "@@string@@" },
  { mime = "{audio,video}/*", fg = "@@string@@" },
  { mime = "application/{zip,gzip,x-tar,x-bzip*,x-7z-compressed,x-rar,x-xz,zstd}", fg = "@@number@@" },
  { url = "*.{pem,key,crt,p12,pfx}", fg = "@@clay@@" },
  { url = "*.{yaml,yml,toml,json,tf,tfvars,hcl,conf,ini,env}", fg = "@@violet@@" },
  { url = "*Dockerfile", fg = "@@violet@@" },
  { url = "*.{log,bak}", fg = "@@linenr@@" },
  { url = "*", is = "orphan", fg = "@@clay@@" },
  { url = "*", is = "exec", fg = "@@function@@" },
  { url = "*", is = "link", fg = "@@violet@@" },
  { url = "*", fg = "@@fg@@" },
  { url = "*/", fg = "@@property@@" },
]
'''


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('kullanim: python3 tools/build.py tools/palettes/<tema>.toml')
    cfg, P = load(sys.argv[1])
    print(f"{cfg['name']} uretiliyor:")
    build(cfg, P)
