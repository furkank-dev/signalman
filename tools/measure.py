#!/usr/bin/env python3
"""
measure.py — bir paletin okunabilirlik raporu.

    python3 tools/measure.py tools/palettes/signal-violet.toml
    python3 tools/measure.py yeni.toml tools/palettes/signal-violet.toml   # karsilastir

Iki olcu:
  APCA Lc   siyah zemine gore kontrast. 45+ okunur, 60+ govde metni.
  dE 2000   iki rengin farki. 3 alti goz ayiramaz, 8+ uzun okumada rahat.

Esikler bu ailenin kurallaridir (Signalman/Guardian/Signal Violet):
  ana kod rolleri birbirinden    dE >= 8
  yapisal tonlar birbirinden     dE >= 5
  duz metin                      Lc 65..80  (en sik token, en sakin olmali)
  yorum                          Lc >= 40
  uyari / hata kod renklerinden  dE >= 12
  regex renkleri kod renklerinden dE >= 8
"""
import itertools
import os
import sys
import tomllib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from colorlib import apca, de2000, hex_to_oklch, resolve  # noqa: E402

MAIN = ['fg', 'keyword', 'function', 'string', 'number', 'type', 'builtin', 'param', 'property']
STRUCT = ['comment', 'operator', 'punct', 'unknown']
ALERTS = [('warn', 'function'), ('warn', 'number'), ('clay', 'number'), ('clay', 'builtin'),
          ('info', 'property')]
REGEX = [('regex', 'string'), ('regex_meta', 'function'), ('regex_meta', 'number')]


def load(path):
    with open(path, 'rb') as f:
        cfg = tomllib.load(f)
    return cfg['name'], {k: resolve(v) for k, v in cfg['colors'].items()}


def ok(cond):
    return '\033[32mOK\033[0m ' if cond else '\033[33m!! \033[0m'


def report(path):
    name, P = load(path)
    print(f'\n━━ {name} ━━')
    print(f'  {"rol":11s} {"hex":8s}  {"Lc":>5s}   OKLCh (L C H)')
    for k in MAIN + STRUCT + ['linenr', 'regex', 'regex_meta', 'warn', 'clay', 'info']:
        L, C, H = hex_to_oklch(P[k])
        print(f'  {k:11s} {P[k]}  {apca(P[k]):5.1f}   {L:.3f} {C:.3f} {H:5.1f}')

    main = sorted((de2000(P[a], P[b]), a, b) for a, b in itertools.combinations(MAIN, 2))
    struct = sorted((de2000(P[a], P[b]), a, b) for a, b in itertools.combinations(MAIN + STRUCT, 2)
                    if a in STRUCT or b in STRUCT)
    print('\n  en yakin ana ciftler:   ' + ', '.join(f'{a}/{b} {d:.1f}' for d, a, b in main[:3]))
    print('  en yakin yapisal:       ' + ', '.join(f'{a}/{b} {d:.1f}' for d, a, b in struct[:3]))
    fg_lc, cm_lc = apca(P['fg']), apca(P['comment'])
    alert_min = min((de2000(P[a], P[b]), a, b) for a, b in ALERTS)
    regex_min = min((de2000(P[a], P[b]), a, b) for a, b in REGEX)
    print()
    print(f'  {ok(main[0][0] >= 8)}ana kod rolleri ayrimi      dE {main[0][0]:.1f}  (>= 8)')
    print(f'  {ok(struct[0][0] >= 5)}yapisal ton ayrimi         dE {struct[0][0]:.1f}  (>= 5)')
    print(f'  {ok(65 <= fg_lc <= 80)}duz metin kontrasti        Lc {fg_lc:.1f}  (65..80)')
    print(f'  {ok(cm_lc >= 40)}yorum kontrasti            Lc {cm_lc:.1f}  (>= 40)')
    print(f'  {ok(alert_min[0] >= 12)}uyari/hata vs kod          dE {alert_min[0]:.1f}  '
          f'({alert_min[1]}/{alert_min[2]}, >= 12)')
    print(f'  {ok(regex_min[0] >= 8)}regex vs kod               dE {regex_min[0]:.1f}  '
          f'({regex_min[1]}/{regex_min[2]}, >= 8)')
    return P


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    pals = [report(p) for p in sys.argv[1:]]
    if len(pals) == 2:
        a, b = pals
        print('\n━━ fark (ilk -> ikinci) ━━')
        for k in a:
            if k in b and a[k] != b[k]:
                print(f'  {k:11s} {a[k]} -> {b[k]}  (dE {de2000(a[k], b[k]):.1f})')
