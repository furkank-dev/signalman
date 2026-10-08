# Changelog

## 2.2.0

Okunabilirlik revizyonu. Tema kimligi (siyah zemin, kehribar kod ekseni,
mor chrome, durust ANSI) degismedi; ayrim ve kontrast olculup duzeltildi.

### Token ayrimi
Onceki surumde alti yapisal sinif — yorum, operator, noktalama, satir
numarasi, parametre ve LSP'nin cozemedigi isimler — CIEDE2000 olcumunde
0.47 ile 4.15 arasindaydi. 3'un altindaki fark ayirt edilemez sayilir;
pratikte alti sinif tek renkti. Ayrim artik tek eksende (parlaklik) degil,
parlaklik x doygunluk x dar bir ton araliginda (OKLCh hue 46-118) yapiliyor.

    yan yana gelen token ciftlerinde en dusuk ayrim   0.47 -> 8.28

### Kontrast (APCA Lc, siyah zemin)
    yorum      33.7 -> 45.9    gunduz laptop ekraninda kayboluyordu
    operator   32.8 -> 52.6    operator anlam tasir, dekor degil
    ozellik    42.8 -> 51.4
    satir no   33.6 -> 27.4    kasten dusuruldu: gutter arayuz, kod degil

### Regex
Regex govdesi tek blok kehribardi. Artik literal karakterler geri cekiliyor
(#D79C80), metakarakterler one cikiyor (#FFC372): quantifier, anchor,
karakter sinifi, kacis dizisi. Gruplar fonksiyon rengiyle. Neovim tarafinda
`@capture.regex` dil-ozel yakalamalari, VSCodium tarafinda TextMate
`*.regexp` kapsamlari kullaniliyor.

### Imlec satiri
`cursorline` varsayilan olarak acik. Dolgu #141110 — siyaha gore L* +5.6,
gorunur ama dikkat dagitmaz. `CursorLineNr` kalin.

### Kabuk
Yeni: `terminal/signalman-shell.sh`. Prompt (git dali, calisma agaci durumu,
sifir olmayan cikis kodu), LS_COLORS/EZA_COLORS, man sayfasi ve grep
renkleri ayni paletten. Editor kehribar, terminal beyaz kaldigi surece tema
yarim goruyordu.

### Lualine
Yeni: `nvim/signalman-lualine-sections.lua` (istege bagli). Satir:sutun
gostergesi saatle karistirilamayacak sekilde yeniden yazildi
(`ln 18/393 - 52`), ayrac yonleri tek yone cevrildi.

### Arac
`:SignalmanCheck` — token gruplarinin cozulmus renklerini ve APCA
kontrastini listeler.

## 2.1.0

The extension now ships one theme. Black, Muted, Clear, Gilded, Cipher and Amber
were exploration steps, not products — keeping six near-identical variants in a
picker is clutter, and every one of them was superseded.

- Fixed nine colours in the VS Code theme that the generator had left unmapped
  from the palette it was derived from. The worst was pure white, used eleven
  times in scrollbar and selection overlays, in a theme whose entire premise is
  that nothing on screen is white. Also a violet-grey used for every disabled and
  inactive label, and two stale hover violets from the old accent family.
- Old generator scripts and per-variant kitty and Neovim files removed.

## 2.0.0

Added **Signalman**, built to four priorities in order.

1. Nothing that costs a security engineer. ANSI is left honest — green reads as
   green — because `git diff`, `pytest`, `trivy` and `semgrep` lean on it.
   Comments sit at 5.15:1. Worst semantic pair is CIEDE2000 18.5.
2. Fits the desktop: violet `#C57AD4` carries chrome and never enters the code.
3. Reads as a terminal: black background, amber-dominant, no white.
4. Monochrome as far as the above allow: code hue spans 80–92 only.
## 3.0.0 — Guardian

Signalman'in yaninda ikinci bir palet: **Guardian**. Eski tema silinmedi,
ikisi de pakette duruyor, istedigin an gecis yapabilirsin.

**Guardian nedir:** soguk celik gri kod ekseni, tek sari aksan (#F3D573).
Kehribarin sicakligi yerine klinik bir ton. Mor sadece secim, arama ve
url'de kaldi — kod alanina girmez ama sistem temasiyla bagi korur.

- imlec ve aktif satir numarasi: sari (#F3D573)
- secim, arama, url, kenarlik: mor (#C57AD4)
- ANSI degismedi: kirmizi/yesil ayrimi ΔE 101, git diff ve trivy bozulmuyor
- olcum: minΔE 4.30, minKontrast 4.34, 3'un altinda cift yok

**Bilinen takas:** ayrim Signalman'in yarisi (8.45 -> 4.30). En yakin ciftler
`armour/unknown` (4.30) ve `gold/gold_mid` yani keyword/string (4.68).
Uzun kod inceleme oturumlarinda goz bir tik daha calisir. Karsiliginda
ekran belirgin sekilde daha ciddi ve tek aksan odagi keskinlesir.

## 3.1.0 — Signal Violet

Ucuncu palet: **Signal Violet**. Signalman ve Guardian silinmedi, uc tema
da pakette.

**Signal Violet nedir:** masaustunun iki rengi koda tasindi. Anahtar
kelimeler waybar moru (#C57AD4), fonksiyonlar waybar sarisi (#F5C842).
Geri kalan her rol kendi tonunda: string fosfor yesili, sayi mercan, tip
lilaya calan buz beyazi, self/True/dekorator gul, parametre lavanta-gri
(italik), ozellik soguk camgobegi. Mor bu temada bilerek koda giriyor;
Signalman/Guardian'daki "mor sadece chrome" kurali burada yok.

Neden: Guardian'da anahtar kelime, string ve duz metin ayni gri bantta
duruyordu (dE 3.5-4.3), uzun oturumda goz bunlari ayirmak icin calisiyordu.

- ana kod tokenlari arasinda en dusuk ayrim: Guardian 3.5 -> 8.8
- yapisal tonlar (yorum/noktalama/cozulmemis isim): 4.3 -> 7.1
- uyari rengi fonksiyon sarisindan ayrildi: turuncu #FB9437 (dE 20.4)
- yorum ve parametre italik
- ANSI degismedi: kirmizi/yesil ayrimi korunuyor, sadece duz metin rengi
  (color7/color15) paletle ayni
- `:SignalVioletCheck` komutu

**Bilinen takas:** anahtar kelime rengi masaustundeki morun birebir
kendisi oldugu icin kontrasti Guardian'in gri anahtar kelimesinden dusuk
(APCA Lc 46, Signalman'in anahtar kelimesiyle ayni seviye). Seyrek token
oldugu icin okumayi bozmaz; karsiliginda editor ve masaustu tek parca
gorunur.

## 3.1.1 — Signal Violet: Yazi, bat, delta, fzf

Renkler 3.1.0 ile ayni; tema artik editor disindaki araclara da uzaniyor.

- **Yazi flavor** (`yazi/signal-violet.yazi/`): mod rozeti mor, sekme ve
  imlec sari, dosya turleri LS_COLORS ile ayni rollerde. Kod onizlemesi
  kendi `tmtheme.xml`'i ile Neovim ve VSCodium'la ayni renklerde.
- **tmTheme** (`terminal/signal-violet.tmTheme`): VSCodium kurallarindan
  uretildi; bat ve delta bunu kullanir. Kabuk dosyasi tema kuruluysa
  `BAT_THEME=signal-violet`, degilse eskisi gibi `ansi`.
- **fzf**: eslesme mor, secili satir koyu mor zemin + sari isaretci.
  Kabuk dosyasi iki kez source edilse de renk bir kez eklenir.
- zsh-autosuggestions onerisi Signalman'dan kalan griden paletin gutter
  tonuna alindi.
- VSCodium/tmTheme: `self` ve dekoratorler Sublime/bat kapsam adlariyla da
  (`variable.language`, `meta.annotation`) gul rengini aliyor.

## 3.2.0 — Signal Violet: duz metin sakinlesti

Gercek ekranda (kitty, Iosevka 12.5) duz metin fazla parlak ve kalin
okunuyordu. Ekranda en sik gorunen token degisken adlari; Signalman'in
kurali "en sik token en sakin olan" 3.1'de bozulmustu.

- duz metin #DFDDE4 -> #CBC9D0 (Lc 86.6 -> 74.5, Guardian 74.1 ile ayni
  seviye). Siyah zeminde parlak metnin yarattigi "kalin" etkisi azaldi.
- tipler/siniflar/istisnalar #E0DDFB -> #C0D0F9 (mavi-lila). Eskisi duz
  metinle neredeyse ayni beyazdi; artik `ValueError` gibi isimler ayri.
- ana kod tokenlari arasinda en dusuk ayrim 8.8 -> 9.8
- mor, sari, yesil, mercan, gul ve diger roller degismedi.
- kitty color7/color15, kabuk prompt'u, lualine, Yazi ve bat ayni
  degerlerden yeniden uretildi.

## 3.2.1 — Signal Violet: tools/ uretim hatti

Renkler 3.2.0 ile ayni. Temalar artik elle degil, tek bir palet dosyasindan
uretiliyor; yeni tema yapmak "paleti sec, script'i calistir" haline geldi.

- `tools/palettes/signal-violet.toml`: Signal Violet'in tek kaynagi.
  Renkler `#RRGGBB` ya da `oklch L C H` olarak yazilir.
- `tools/build.py`: paletten Neovim, lualine, kitty, kabuk, VSCodium,
  tmTheme ve Yazi dosyalarini uretir; yeni temayi package.json'a kaydeder.
  Signal Violet'in repodaki dosyalarini bayt bayt ayni uretir.
- `tools/measure.py`: kontrast (APCA) ve ayrim (CIEDE2000) raporu, esik
  kontrolleriyle; iki paleti karsilastirabilir.
- `tools/preview.py`: paletleri tarayicida Neovim penceresi gibi gosterir.
- `tools/install.sh`: temayi bu bilgisayara kurar (Neovim, kitty, kabuk,
  Yazi, bat, VSCodium) ve onceki temadan gecisi yapar; kalan eski ayarlari
  listeler.
- `tools/release.sh`: surumu etiketler, `.vsix` paketler, GitHub release
  acar.
- Ayrintilar: `tools/README.md`. `tools/` `.vsix` paketine girmez.

## 3.3.0 — Nazarick: siyah, altin, celik

Dorduncu palet. Masaustu artik Nazarick wallpaper'i ve "Mum Isigi" paletinde
(dotfiles); kod temasi ona uyuyor. Kural: siyah zemin, masaustu altini ana
renk, tek soguk renk (celik), dusuk doygunluk.

- anahtar kelimeler, prompt, Neovim mod rozeti, kitty sekmesi: altin #E0B878
- fonksiyonlar soluk krem (ekranin en parlak tokeni), stringler soluk deniz
  yesili, sayilar bakir, tipler buz celigi, self/True/dekorator celik mavisi
- olcumler: ana roller arasi en dusuk ayrim dE 9.9, duz metin Lc 74.5,
  yorum Lc 47, uyari vs kod dE 12.9
- butun hedefler tools/ hattindan uretildi: Neovim + lualine, kitty, kabuk,
  VSCodium, tmTheme (bat/delta), Yazi flavor
- build.py: Guardian kaliplarindaki mor #C57AD4 (kitty secimi, link rengi,
  VSCodium chrome) artik palet rengine cevriliyor. Signal Violet'te ayni
  renk oldugu icin fark edilmemisti; Signal Violet dosyalari degismedi.
- install.sh: dosya duzenlerken `sed -i --follow-symlinks`. Duz `sed -i`,
  stow'un symlink'ini (~/.zshrc, VSCodium settings.json) normal dosyaya
  ceviriyordu; degisiklik dotfiles reposuna yansimiyordu.

## 3.3.1 — prompt: ops baglami (k8s / aws / docker)

Dort temanin kabuk dosyasinda prompt artik, sadece aktifken, hangi ortama
bagli oldugunu gosteriyor:

    [psik0t@basti0n homelab k8s:kind-homelab aws:dev main*]$

- k8s: ~/.kube/config'teki (ya da $KUBECONFIG) current-context
- aws: $AWS_PROFILE ayarliysa
- docker: varsayilan olmayan context ($DOCKER_CONTEXT ya da ~/.docker/config.json)
- Hicbiri yoksa prompt eskisi gibi. kubectl/docker calistirilmaz, ayar
  dosyalari okunur: satir basina ~4 ms.
- Amac: yanlis cluster'a / hesaba komut atmamak.
