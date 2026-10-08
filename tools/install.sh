#!/usr/bin/env bash
# install.sh — bir temayi bu bilgisayara kurar ve onceki temadan gecis yapar.
#
#   tools/install.sh signal-violet              # repo kokunden calistir
#   tools/install.sh signal-violet --from guardian
#
# Onceki tema --from verilmezse Neovim ayarindan (plugins/colorscheme.lua)
# okunur. Kurulanlar: Neovim + lualine, kitty, kabuk paleti, Yazi flavor,
# bat/delta temasi, VSCodium (vsix varsa). En sonda onceki temaya isaret
# eden baska ayar kaldiysa listeler.
#
# Tekrar calistirmak guvenli. Geri donus: tools/install.sh <eski-tema>
# (ya da ayarlar ~/.dotfiles'taysa: git -C ~/.dotfiles checkout .)

set -euo pipefail

ok()   { printf '\033[38;2;135;228;150m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[38;2;251;148;55m  !\033[0m %s\n' "$*"; }
step() { printf '\n\033[38;2;197;122;212m▸ %s\033[0m\n' "$*"; }

SLUG="${1:-}"
[ -n "$SLUG" ] || { echo "kullanim: tools/install.sh <tema> [--from <eski-tema>]"; exit 1; }
OLD=""
if [ "${2:-}" = "--from" ]; then OLD="${3:-}"; fi

cd "$(dirname "$0")/.."
[ -f "nvim/$SLUG.lua" ] || { echo "nvim/$SLUG.lua yok. Once: python3 tools/build.py tools/palettes/$SLUG.toml"; exit 1; }
NAME=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['name'])" "themes/$SLUG-color-theme.json")

NV="$HOME/.config/nvim"
if [ -z "$OLD" ] && [ -f "$NV/lua/plugins/colorscheme.lua" ]; then
  OLD=$(grep -o 'colorscheme = "[^"]*"' "$NV/lua/plugins/colorscheme.lua" | head -n1 | cut -d'"' -f2 || true)
fi
[ "$OLD" = "$SLUG" ] && OLD=""
echo "Kurulan: $NAME ($SLUG)${OLD:+  ·  onceki: $OLD}"

step "Neovim"
mkdir -p "$NV/lua/lualine/themes" "$NV/colors"
cp "nvim/$SLUG.lua" "$NV/lua/$SLUG.lua"
cp "nvim/$SLUG-lualine.lua" "$NV/lua/lualine/themes/$SLUG.lua"
echo "require('$SLUG').load()" > "$NV/colors/$SLUG.lua"
ok "tema, lualine temasi, colors/ yukleyicisi"
if [ -n "$OLD" ]; then
  for f in "$NV/lua/plugins/colorscheme.lua" "$NV/lua/config/lazy.lua"; do
    if [ -f "$f" ] && grep -q "\"$OLD\"" "$f"; then
      sed -i --follow-symlinks "s/\"$OLD\"/\"$SLUG\"/g" "$f"; ok "$OLD → $SLUG: ${f#"$HOME"/}"
    fi
  done
fi
LS="$NV/lua/plugins/signalman-lualine.lua"
if [ -f "$LS" ]; then cp "nvim/$SLUG-lualine-sections.lua" "$LS"; ok "lualine yerlesimi"; fi

step "kitty"
KD="$HOME/.config/kitty"
if [ -d "$KD" ]; then
  cp "terminal/$SLUG.conf" "$KD/$SLUG.conf"
  if grep -q "include.*$SLUG\.conf" "$KD/kitty.conf" 2>/dev/null; then
    ok "kitty.conf zaten $SLUG.conf'u include ediyor"
  elif [ -n "$OLD" ] && grep -q "include.*$OLD\.conf" "$KD/kitty.conf" 2>/dev/null; then
    sed -i --follow-symlinks "s/include\(.*\)$OLD\.conf/include\1$SLUG.conf/" "$KD/kitty.conf"; ok "kitty.conf → $SLUG.conf"
  else
    warn "kitty.conf'un en ustune ekle: include $SLUG.conf"
  fi
  kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null && ok "acik kitty pencereleri yenilendi" || true
fi

step "Kabuk"
mkdir -p "$HOME/.config/signalman"
cp "terminal/$SLUG-shell.sh" "$HOME/.config/signalman/$SLUG-shell.sh"
ok "$SLUG-shell.sh"
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [ -n "$OLD" ] && [ -f "$rc" ] && grep -q "$OLD-shell\.sh" "$rc"; then
    sed -i --follow-symlinks "s/$OLD-shell\.sh/$SLUG-shell.sh/g" "$rc"; ok "${rc#"$HOME"/}"
  fi
done
grep -qs "$SLUG-shell\.sh" "$HOME/.zshrc" || \
  warn ".zshrc'ye ekle: [ -f ~/.config/signalman/$SLUG-shell.sh ] && . ~/.config/signalman/$SLUG-shell.sh"

step "Yazi"
if command -v yazi >/dev/null && [ -d "yazi/$SLUG.yazi" ]; then
  YD="$HOME/.config/yazi"; TT="$YD/theme.toml"
  mkdir -p "$YD/flavors"
  rm -rf "$YD/flavors/$SLUG.yazi"; cp -r "yazi/$SLUG.yazi" "$YD/flavors/"
  ok "flavor: flavors/$SLUG.yazi"
  if [ -f "$TT" ] && grep -q "^dark *= *\"$SLUG\"" "$TT"; then
    ok "theme.toml zaten $SLUG"
  elif [ -f "$TT" ] && grep -q '^\[flavor\]' "$TT" && ! grep -qv -e '^\[flavor\]' -e '^dark *=' -e '^light *=' -e '^#' -e '^$' "$TT"; then
    sed -i --follow-symlinks "s/^dark *= *\".*\"/dark = \"$SLUG\"/" "$TT"; ok "theme.toml → dark = \"$SLUG\""
  else
    # theme.toml'daki her renk flavor'i ezer; o yuzden sadece [flavor] birakilir.
    [ -f "$TT" ] && cp "$TT" "$TT.bak" && ok "eski theme.toml yedeklendi: theme.toml.bak"
    printf '# Renkler flavors/%s.yazi icinde. Eski ayarlar varsa .bak dosyasinda.\n\n[flavor]\ndark = "%s"\n' "$SLUG" "$SLUG" > "$TT"
    ok "theme.toml → dark = \"$SLUG\""
  fi
else
  warn "yazi yok ya da bu temanin flavor'u yok, atlandi"
fi

step "bat / delta"
if command -v bat >/dev/null && [ -f "terminal/$SLUG.tmTheme" ]; then
  BD="$(bat --config-dir)/themes"; mkdir -p "$BD"
  cp "terminal/$SLUG.tmTheme" "$BD/$SLUG.tmTheme"
  bat cache --build >/dev/null
  ok "bat temasi (yeni terminalde BAT_THEME=$SLUG)"
else
  warn "bat yok ya da tmTheme yok, atlandi"
fi

step "VSCodium"
# shellcheck disable=SC2012  # dosya adlari sabit kalip: signalman-X.Y.Z.vsix
VSIX=$(ls -t signalman-*.vsix "$HOME"/Downloads/signalman-*.vsix 2>/dev/null | head -n1 || true)
if command -v codium >/dev/null; then
  if [ -n "$VSIX" ]; then codium --install-extension "$VSIX" --force >/dev/null && ok "eklenti: $(basename "$VSIX")"; fi
  SJ="$HOME/.config/VSCodium/User/settings.json"
  if [ -f "$SJ" ] && grep -q '"workbench.colorTheme"' "$SJ"; then
    sed -i --follow-symlinks "s/\"workbench.colorTheme\": *\"[^\"]*\"/\"workbench.colorTheme\": \"$NAME\"/" "$SJ"; ok "VSCodium temasi: $NAME"
  else
    warn "VSCodium'da Ctrl+K Ctrl+T → $NAME"
  fi
else
  warn "codium yok, atlandi"
fi

if [ -n "$OLD" ]; then
  step "Kalan '$OLD' izleri"
  LEFT=$(grep -rIl -i -- "$OLD" "$HOME/.config" "$HOME/.zshrc" "$HOME/.bashrc" 2>/dev/null \
    | grep -v -e "/${OLD}[^/]*\$" -e "/${SLUG}[^/]*\$" -e "/${OLD}\.yazi/" -e "/${SLUG}\.yazi/" \
              -e '\.bak$' -e '/\.git/' -e '/BraveSoftware/' -e '/mozilla/' \
              -e '/VSCodium/' -e '/Code - OSS/' -e '/chromium/' -e '/discord/' || true)
  if [ -z "$LEFT" ]; then ok "baska ayar kalmadi"; else
    warn "bu dosyalarda hala '$OLD' geciyor:"; printf '%s\n' "$LEFT" | sed "s|^$HOME|    ~|"
  fi
fi

step "Bitti"
echo "  Neovim'i yeniden ac → :$(echo "$NAME" | tr -d ' ')Check"
echo "  Yeni terminal ac, Yazi'yi yeniden baslat."
