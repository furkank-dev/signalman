#!/usr/bin/env python3
"""
preview.py — paletleri tarayicida yan yana gosterir (Neovim penceresi gibi).

    python3 tools/preview.py tools/palettes/signal-violet.toml
    python3 tools/preview.py yeni.toml tools/palettes/signal-violet.toml -o karsilastirma.html

Her kartta: kod, imlec satiri, secili kelime, satir sonu uyarisi, durum
cubugu ve terminal ciktisi. Bu sadece hizli bir bakis; son karar icin
temayi uretip Neovim'de ac (bkz. README).
"""
import html
import itertools
import os
import sys
import tomllib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from colorlib import apca, de2000, resolve  # noqa: E402

MAIN = ['fg', 'keyword', 'function', 'string', 'number', 'type', 'builtin', 'param', 'property']


def load(path):
    with open(path, 'rb') as f:
        cfg = tomllib.load(f)
    return cfg['name'], {k: resolve(v) for k, v in cfg['colors'].items()}


def code_lines(P):
    def S(t, role, extra=''):
        return f'<span style="color:{P[role]}{extra}">{html.escape(t)}</span>'
    k = lambda t: S(t, 'keyword')            # noqa: E731
    f = lambda t: S(t, 'function')           # noqa: E731
    s = lambda t: S(t, 'string')             # noqa: E731
    n = lambda t: S(t, 'number')             # noqa: E731
    ty = lambda t: S(t, 'type')              # noqa: E731
    b = lambda t: S(t, 'builtin')            # noqa: E731
    pa = lambda t: S(t, 'param', ';font-style:italic')    # noqa: E731
    pr = lambda t: S(t, 'property')          # noqa: E731
    o = lambda t: S(t, 'operator')           # noqa: E731
    pu = lambda t: S(t, 'punct')             # noqa: E731
    fg = lambda t: S(t, 'fg')                # noqa: E731
    cm = lambda t: S(t, 'comment', ';font-style:italic')  # noqa: E731
    rx = lambda t: S(t, 'regex')             # noqa: E731
    rm = lambda t: S(t, 'regex_meta')        # noqa: E731
    return [
        cm('# secret_sniffer.py — tarayici'),
        k('import') + fg(' re') + pu(', ') + fg('sys'),
        n('PATTERN') + o(' = ') + fg('re') + pu('.') + f('compile') + pu('(') + s('r"') + rm('\\b') + rx('AKIA')
        + rm('[0-9A-Z]{16}') + s('"') + pu(')'),
        '',
        b('@dataclass') + pu('(') + pa('frozen') + o('=') + b('True') + pu(')'),
        k('class') + fg(' ') + ty('Finding') + pu(':'),
        fg('    ') + pr('path') + pu(': ') + ty('Path'),
        fg('    ') + pr('line_no') + pu(': ') + ty('int') + o(' = ') + n('0'),
        '',
        fg('    ') + k('def') + fg(' ') + f('masked') + pu('(') + b('self') + pu(', ') + pa('keep') + pu(': ')
        + ty('int') + o(' = ') + n('4') + pu(') ') + o('->') + fg(' ') + ty('str') + pu(':'),
        fg('        ') + k('if') + fg(' ') + f('len') + pu('(') + b('self') + pu('.') + pr('secret') + pu(') ')
        + o('<=') + fg(' ') + pa('keep') + fg(' ') + k('and not') + fg(' ') + b('None') + pu(':'),
        fg('            ') + k('return') + fg(' ') + s('"*"') + o(' * ') + f('len') + pu('(') + b('self')
        + pu('.') + pr('secret') + pu(')'),
        fg('        ') + k('return') + fg(' ') + b('self') + pu('.') + pr('secret') + pu('[:') + pa('keep')
        + pu('] + ') + s('"…"'),
        '',
        k('def') + fg(' ') + f('scan') + pu('(') + pa('root') + pu(': ') + ty('Path') + pu(') ') + o('->')
        + fg(' ') + ty('list') + pu('[') + ty('Finding') + pu(']:'),
        fg('    ') + k('for') + fg(' path ') + k('in') + fg(' ') + pa('root') + pu('.') + f('rglob') + pu('(')
        + s('"*"') + pu('):'),
        fg('        ') + k('try') + pu(':'),
        fg('            ') + fg('data') + o(' = ') + fg('path') + pu('.') + f('read_text') + pu('()'),
        fg('        ') + k('except') + fg(' ') + ty('OSError') + fg(' ') + k('as') + fg(' err') + pu(':'),
        fg('            ') + f('print') + pu('(') + s('f"[!] ') + n('{') + fg('path') + n('}') + s(': ')
        + n('{') + fg('err') + n('}') + s('"') + pu(')'),
    ]


def card(name, P):
    rows = []
    for i, line in enumerate(code_lines(P), 1):
        cur = i == 11
        bg = f'background:{P["bg_line"]};' if cur else ''
        nr_col = P['function'] if cur else P['linenr']
        nr = f'<span class="nr" style="color:{nr_col};{"font-weight:700" if cur else ""}">{i:>3}</span>'
        if i == 16:
            line = line.replace('rglob', f'</span><span style="background:{P["bg_sel"]};color:{P["function"]}">rglob')
        diag = f'<span style="color:{P["warn"]};opacity:.75;font-style:italic">  ● W605 kacis dizisi</span>' if i == 3 else ''
        rows.append(f'<div class="ln" style="{bg}">{nr} {line or " "}{diag}</div>')
    status = (f'<div class="st" style="background:{P["bg_elev"]}">'
              f'<span style="background:{P["violet"]};color:#000;padding:0 8px;font-weight:700">NORMAL</span>'
              f'<span style="color:{P["fg"]};padding:0 10px">main</span>'
              f'<span style="color:{P["punct"]}">secret_sniffer.py</span>'
              f'<span style="margin-left:auto;color:{P["function"]};padding-right:8px">ln 11/20 · 9</span></div>')
    term = (f'<div class="term"><span style="color:{P["violet"]}">[</span><span style="color:{P["keyword"]}">kaya</span>'
            f'<span style="color:{P["punct"]}">@host </span><span style="color:{P["string"]}">~/dev</span>'
            f'<span style="color:{P["property"]}"> main*</span><span style="color:{P["violet"]}">]</span>'
            f'<span style="color:{P["function"]}">$ </span><span style="color:{P["fg"]}">pytest -q</span><br>'
            f'<span style="color:{P["sage"]}">12 passed</span><span style="color:{P["operator"]}">, </span>'
            f'<span style="color:{P["clay"]}">1 failed</span><span style="color:{P["comment"]}"> in 0.42s</span></div>')
    swatch = ''.join(f'<i title="{k} {P[k]}" style="background:{P[k]}"></i>'
                     for k in MAIN + ['comment', 'warn'])
    main_min = min(de2000(P[a], P[b]) for a, b in itertools.combinations(MAIN, 2))
    return (f'<section class="card"><h2>{html.escape(name)}</h2><div class="sw">{swatch}'
            f'<span class="m">ayrim dE {main_min:.1f} · duz metin Lc {apca(P["fg"]):.0f} · '
            f'yorum Lc {apca(P["comment"]):.0f}</span></div>'
            f'<div class="win">{"".join(rows)}{status}</div>{term}</section>')


def page(cards):
    return f'''<!doctype html><html lang="tr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Tema Onizleme</title><style>
*{{box-sizing:border-box}} body{{background:#000;color:#ccc;margin:0;padding:20px 16px;
font-family:"Iosevka Nerd Font Mono","Iosevka","JetBrains Mono",ui-monospace,monospace}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(min(100%,560px),1fr));gap:16px}}
.card{{border:1px solid #1c1c22;border-radius:10px;padding:12px}} h2{{font-size:15px;margin:0 0 8px;color:#eee}}
.sw{{display:flex;gap:3px;align-items:center;margin-bottom:8px;flex-wrap:wrap}} .sw i{{width:18px;height:11px;border-radius:2px}}
.m{{color:#777;font-size:11px;margin-left:8px}}
.win{{background:#000;border:1px solid #1c1c1c;border-radius:6px;overflow-x:auto;padding-top:6px}}
.ln{{white-space:pre;font-size:13.5px;line-height:1.55;padding-right:10px}}
.nr{{display:inline-block;width:3em;text-align:right;padding-right:.6em;user-select:none}}
.st{{display:flex;font-size:12.5px;margin-top:6px;line-height:1.7;white-space:nowrap}}
.term{{border:1px solid #1c1c1c;border-radius:6px;margin-top:8px;padding:6px 10px;font-size:13px;line-height:1.6}}
</style></head><body><div class="grid">{"".join(cards)}</div></body></html>'''


if __name__ == '__main__':
    args = sys.argv[1:]
    out = None
    if '-o' in args:
        i = args.index('-o')
        out = args[i + 1]
        del args[i:i + 2]
    if not args:
        sys.exit(__doc__)
    loaded = [load(p) for p in args]
    out = out or (os.path.splitext(os.path.basename(args[0]))[0] + '-onizleme.html')
    with open(out, 'w', encoding='utf-8') as f:
        f.write(page([card(n, P) for n, P in loaded]))
    print('yazildi:', out, '— tarayicida ac: xdg-open', out)
