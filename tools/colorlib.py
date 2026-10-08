"""
colorlib.py — tema araclarinin renk matematigi.

Hicbir disaridan paket gerektirmez (sadece Python standart kutuphanesi).

  oklch_to_hex(L, C, H)  -> '#RRGGBB'   algisal olarak duzgun renk uzayi
  hex_to_oklch('#...')   -> (L, C, H)
  resolve(deger)         -> '#RRGGBB'   palet dosyasindaki "oklch 0.84 0.01 300"
                                         ya da "#C57AD4" yazimini cozer
  de2000(a, b)           -> CIEDE2000 ayrim. 3 alti: goz ayiramaz, 8+: rahat
  apca(fg, bg)           -> APCA Lc kontrast. 45+: okunur, 60+: govde metni
"""
import math


# ── sRGB <-> dogrusal ────────────────────────────────────────────────
def _lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def _enc(x):
    x = max(0.0, min(1.0, x))
    x = 12.92 * x if x <= 0.0031308 else 1.055 * x ** (1 / 2.4) - 0.055
    return round(x * 255)


def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rgb_triplet(h):
    """'#C57AD4' -> '197;122;212' (ANSI 24-bit kacis dizileri icin)."""
    return ';'.join(str(v) for v in hex_to_rgb(h))


# ── OKLCh ────────────────────────────────────────────────────────────
def oklch_to_hex(L, C, H):
    a = C * math.cos(math.radians(H))
    b = C * math.sin(math.radians(H))
    l_ = L + 0.3963377774 * a + 0.2158037573 * b
    m_ = L - 0.1055613458 * a - 0.0638541728 * b
    s_ = L - 0.0894841775 * a - 1.2914855480 * b
    l, m, s = l_ ** 3, m_ ** 3, s_ ** 3
    r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    bb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    return '#%02X%02X%02X' % (_enc(r), _enc(g), _enc(bb))


def hex_to_oklch(h):
    r, g, b = [_lin(x) for x in hex_to_rgb(h)]
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l, m, s = [x ** (1 / 3) for x in (l, m, s)]
    L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
    a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
    bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    return L, math.hypot(a, bb), math.degrees(math.atan2(bb, a)) % 360


def resolve(value):
    """Palet degerini hex'e cevirir: '#RRGGBB' ya da 'oklch L C H'."""
    v = value.strip()
    if v.startswith('#'):
        return v.upper()
    parts = v.split()
    if parts[0].lower() != 'oklch' or len(parts) != 4:
        raise ValueError(f'anlasilmayan renk: {value!r} ("#RRGGBB" ya da "oklch L C H")')
    return oklch_to_hex(float(parts[1]), float(parts[2]), float(parts[3]))


# ── CIELAB + CIEDE2000 ───────────────────────────────────────────────
def _lab(h):
    r, g, b = [_lin(x) for x in hex_to_rgb(h)]
    X = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047
    Y = (0.2126729 * r + 0.7151522 * g + 0.0721750 * b) / 1.0
    Z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883

    def f(t):
        return t ** (1 / 3) if t > 216 / 24389 else (24389 / 27 * t + 16) / 116
    fx, fy, fz = f(X), f(Y), f(Z)
    return 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)


def de2000(h1, h2):
    L1, a1, b1 = _lab(h1)
    L2, a2, b2 = _lab(h2)
    C1, C2 = math.hypot(a1, b1), math.hypot(a2, b2)
    Cb = (C1 + C2) / 2
    G = 0.5 * (1 - math.sqrt(Cb ** 7 / (Cb ** 7 + 25 ** 7)))
    a1p, a2p = (1 + G) * a1, (1 + G) * a2
    C1p, C2p = math.hypot(a1p, b1), math.hypot(a2p, b2)
    h1p = math.degrees(math.atan2(b1, a1p)) % 360
    h2p = math.degrees(math.atan2(b2, a2p)) % 360
    dL, dC = L2 - L1, C2p - C1p
    if C1p * C2p == 0:
        dh = 0
    else:
        dh = h2p - h1p
        if dh > 180:
            dh -= 360
        elif dh < -180:
            dh += 360
    dH = 2 * math.sqrt(C1p * C2p) * math.sin(math.radians(dh / 2))
    Lb, Cbp = (L1 + L2) / 2, (C1p + C2p) / 2
    if C1p * C2p == 0:
        hb = h1p + h2p
    elif abs(h1p - h2p) <= 180:
        hb = (h1p + h2p) / 2
    else:
        hb = (h1p + h2p + 360) / 2 if h1p + h2p < 360 else (h1p + h2p - 360) / 2
    T = (1 - 0.17 * math.cos(math.radians(hb - 30)) + 0.24 * math.cos(math.radians(2 * hb))
         + 0.32 * math.cos(math.radians(3 * hb + 6)) - 0.20 * math.cos(math.radians(4 * hb - 63)))
    dth = 30 * math.exp(-((hb - 275) / 25) ** 2)
    Rc = 2 * math.sqrt(Cbp ** 7 / (Cbp ** 7 + 25 ** 7))
    Sl = 1 + 0.015 * (Lb - 50) ** 2 / math.sqrt(20 + (Lb - 50) ** 2)
    Sc, Sh = 1 + 0.045 * Cbp, 1 + 0.015 * Cbp * T
    Rt = -math.sin(math.radians(2 * dth)) * Rc
    return math.sqrt((dL / Sl) ** 2 + (dC / Sc) ** 2 + (dH / Sh) ** 2 + Rt * (dC / Sc) * (dH / Sh))


# ── APCA (0.0.98G) ───────────────────────────────────────────────────
def apca(fg, bg='#000000'):
    def Y(h):
        r, g, b = [(x / 255) ** 2.4 for x in hex_to_rgb(h)]
        return 0.2126729 * r + 0.7151522 * g + 0.0721750 * b

    def clamp(y):
        return y if y > 0.022 else y + (0.022 - y) ** 1.414
    Yt, Yb = clamp(Y(fg)), clamp(Y(bg))
    if Yb > Yt:
        S = (Yb ** 0.56 - Yt ** 0.57) * 1.14
        return 0.0 if S < 0.1 else (S - 0.027) * 100
    S = (Yb ** 0.65 - Yt ** 0.62) * 1.14
    return 0.0 if abs(S) < 0.1 else abs((S + 0.027) * 100)
