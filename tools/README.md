# tools/ — tema uretim hatti

Bu klasor, paketteki temalarin nasil uretildigini kaydeder. Yeni bir tema
yapmak ya da mevcut birinin rengini degistirmek icin buradan basla.
Sadece Python 3.11+ (standart kutuphane) gerekir; yayinlamak icin ayrica
`node`/`npx` ve `gh`.

| Dosya | Ne yapar |
|---|---|
| `palettes/<tema>.toml` | Temanin **tek kaynagi**: renkler + dosya basliklarindaki aciklamalar |
| `colorlib.py` | Renk matematigi: OKLCh, CIEDE2000 (ayrim), APCA (kontrast) |
| `measure.py` | Paletin okunabilirlik raporu, esik kontrolleriyle |
| `preview.py` | Paletleri tarayicida Neovim penceresi gibi yan yana gosterir |
| `build.py` | Paletten butun tema dosyalarini uretir |
| `install.sh` | Temayi bu bilgisayara kurar, onceki temadan gecis yapar |
| `release.sh` | `package.json` surumunu etiketler, `.vsix` paketler, GitHub release acar |

## Renk yazimi

Palette her renk ya `"#RRGGBB"` ya da `"oklch L C H"`:

- **L** parlaklik: 0 siyah, 1 beyaz. Siyah zeminde kod renkleri 0.70–0.87 arasi.
- **C** doygunluk: 0 gri, 0.05 hafif tint, 0.10+ belirgin renk, 0.15+ canli.
- **H** ton acisi: 0 pembe-kirmizi · 40 mercan · 60 turuncu · 95 sari ·
  150 yesil · 200 camgobegi · 265 mavi-lila · 300 mor · 355 gul.

OKLCh algisal olarak duzgun: L'yi 0.05 dusurmek her tonda ayni miktarda
"sonuklestirir". Bir rengi soldurmak icin C'yi, parlatmak icin L'yi,
kaydirmak icin H'yi degistir.

## Yeni tema: adim adim

```sh
cd ~/dev/projects/bastion-black

# 1. Mevcut bir paleti kopyala, adini ve renkleri degistir
cp tools/palettes/signal-violet.toml tools/palettes/yeni-tema.toml
#    name, slug, shell_prefix ve [colors] bolumunu duzenle;
#    [text] icindeki aciklamalari da yeni temaya gore yaz.

# 2. Olc. Hepsi OK olana kadar renkleri ayarla.
python3 tools/measure.py tools/palettes/yeni-tema.toml
python3 tools/measure.py tools/palettes/yeni-tema.toml tools/palettes/signal-violet.toml  # karsilastir

# 3. Bak
python3 tools/preview.py tools/palettes/yeni-tema.toml tools/palettes/signal-violet.toml
xdg-open yeni-tema-onizleme.html

# 4. Uret (package.json'a kaydi da ekler)
python3 tools/build.py tools/palettes/yeni-tema.toml

# 5. Kendi bilgisayarinda dene
tools/install.sh yeni-tema
#    Neovim'de :YeniTemaCheck, gercek kodda bak. Gerekirse 1'e don.
#    Begenmezsen geri: tools/install.sh signal-violet

# 6. Surum + CHANGELOG, commit, yayinla
#    package.json "version" alanini artir, CHANGELOG.md'ye "## X.Y.Z — ..." ekle
git add -A && git commit -m "X.Y.Z — Yeni Tema"
tools/release.sh
```

Mevcut temanin bir rengini degistirmek de ayni yol: palette dosyasini
duzenle, 2–6. adimlar.

## Esikler (measure.py)

| Kontrol | Esik | Neden |
|---|---|---|
| Ana kod rolleri arasi ayrim | dE ≥ 8 | 3 altini goz ayiramaz; 8+ uzun okumada rahat |
| Yapisal tonlar (yorum, noktalama…) | dE ≥ 5 | Geride dururlar ama birbirine karismamali |
| Duz metin kontrasti | Lc 65–80 | En sik token. Fazla parlaksa siyah zeminde yazi kalin gorunur |
| Yorum kontrasti | Lc ≥ 40 | Geride ama gunduz de okunmali |
| Uyari/hata vs kod renkleri | dE ≥ 12 | Bir uyari, bir fonksiyon adiyla karistirilmamali |
| Regex vs kod renkleri | dE ≥ 8 | Regex icindeki metakarakterler ayri okunmali |

## build.py nasil calisiyor

Guardian'in dosyalari (`nvim/guardian.lua`, `terminal/guardian.conf`,
`terminal/guardian-shell.sh`, `themes/guardian-color-theme.json`) kalip
olarak kullanilir. Guardian'in her rengi bir role karsilik gelir
(`build.py` icindeki `HEX_ROLES`); o renkler yeni paletin karsiliklariyla
degistirilir. Sonra Guardian'in tek renkte birlestirdigi roller ayrilir:
`self`/`True`/dekorator → `builtin`, parametre → `param` (italik),
uyari → `warn`.

Sonuc: Guardian'a eklenen her duzeltme (yeni bir eklenti grubu, yeni bir
treesitter yakalamasi) bir sonraki `build.py` calismasinda ureyen temaya da
gecer. Kalip disinda bir seyi degistirmek gerekirse `build.py` icinde
`setl(...)` satirlarina bak.

Dogrulama: `python3 tools/build.py tools/palettes/signal-violet.toml`
calistiginda `git status` temiz kalmalidir; Signal Violet'in repodaki
dosyalari bu araclarla bayt bayt ayni uretilir.

## Kapsam disi

Masaustu renkleri (waybar, Hyprland kenarliklari, rofi, swaync, duvar
kagidi) bu repoda degil, dotfiles reposunda. Masaustu paletini de
degistiriyorsan oradaki dosyalari ayrica guncelle.
