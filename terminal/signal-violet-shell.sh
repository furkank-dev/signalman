# ═══════════════════════════════════════════════════════════════════
#  SIGNAL VIOLET — kabuk tarafi   (zsh + bash)
#
#  Editor renkli, terminal duz beyazsa tema yarim kalir. Bu dosya
#  paletin ayni degerlerini prompt'a, ls ciktisina, man sayfalarina ve
#  grep eslesmelerine tasir.
#
#  Kurulum — .zshrc icine:
#     [ -f ~/.config/signalman/signal-violet-shell.sh ] && . ~/.config/signalman/signal-violet-shell.sh
#
#  Not: prompt icin zsh ve bash ayri ayri ele alinir. zsh'ta
#  non-printing diziler %{...%} ile, bash'te \001\002 ile isaretlenir;
#  yanlis olani kullanmak satir sarmasini bozar (uzun komutta imlec kayar).
# ═══════════════════════════════════════════════════════════════════

# ── palet ──────────────────────────────────────────────────────────
# nvim/signal-violet.lua ve terminal/signal-violet.conf ile ayni degerler.
__sv_violet='197;122;212'  # #C57AD4  chrome
__sv_gold='197;122;212'  # #C57AD4  keyword
__sv_gold_pale='245;200;66'  # #F5C842  function
__sv_gold_mid='135;228;150'  # #87E496  string
__sv_cream='247;162;132'  # #F7A284  number
__sv_steel='224;221;251'  # #E0DDFB  type
__sv_steel_dim='140;187;190'  # #8CBBBE  property
__sv_fg='223;221;228'  # #DFDDE4  text
__sv_punct='129;126;136'  # #817E88  punctuation
__sv_dim='106;103;111'  # #6A676F  gutter
__sv_clay='255;112;97'  # #FF7061  error
__sv_sage='88;190;108'  # #58BE6C  ok

# ── git durumu (kabuktan bagimsiz) ─────────────────────────────────
__signal_violet_git() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  local branch dirty
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  [ -z "$branch" ] && return
  # Kirli sayilan uc durum: calisma agaci, staged degisiklik, izlenmeyen dosya.
  if ! git diff --no-ext-diff --quiet 2>/dev/null \
     || ! git diff --no-ext-diff --cached --quiet 2>/dev/null \
     || [ -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -n1)" ]; then
    dirty="*"
  else
    dirty=""
  fi
  printf '%s' " ${branch}${dirty}"
}

# ═══ ZSH ═══════════════════════════════════════════════════════════
if [ -n "${ZSH_VERSION:-}" ]; then

  # %{...%} = "bu diziler ekranda yer kaplamaz". Bash'in \001\002'sinin
  # zsh karsiligi. Atlanirsa uzun komut satirlarinda imlec konumu kayar.
  __sv_zc() { printf '%%{\033[38;2;%sm%%}' "$1"; }
  __sv_zrst='%{\033[0m%}'

  __signal_violet_prompt() {
    local code=$?
    local B U H D G R
    B=$(__sv_zc "$__sv_violet")      # parantezler
    U=$(__sv_zc "$__sv_gold")        # kullanici
    H=$(__sv_zc "$__sv_punct")       # @makine
    D=$(__sv_zc "$__sv_gold_mid")    # dizin
    G=$(__sv_zc "$__sv_steel_dim")   # git
    R=$(printf '%%{\033[0m%%}')

    local git_part
    git_part=$(__signal_violet_git)
    # Dal adinda % gecerse zsh onu prompt kodu sanar; kacisla.
    git_part=${git_part//\%/%%}
    [ -n "$git_part" ] && git_part="${G}${git_part}${R}"

    local tail_part code_part
    if [ "$code" -ne 0 ]; then
      tail_part="$(__sv_zc "$__sv_clay")%(!.#.$)${R} "
      code_part=" $(__sv_zc "$__sv_clay")${code}${R}"
    else
      tail_part="$(__sv_zc "$__sv_gold_pale")%(!.#.$)${R} "
      code_part=""
    fi

    # %n kullanici, %m makine, %1~ bulunulan dizin (bash'teki \W)
    PS1="${B}[${R}${U}%n${R}${H}@%m${R} ${D}%1~${R}${git_part}${code_part}${B}]${R}${tail_part}"
  }

  # precmd_functions = zsh'in PROMPT_COMMAND karsiligi. Ayni fonksiyonu
  # iki kez eklememek icin once kontrol et (dosya tekrar source edilirse).
  typeset -ga precmd_functions
  case " ${precmd_functions[*]} " in
    *" __signal_violet_prompt "*) ;;
    *) precmd_functions+=(__signal_violet_prompt) ;;
  esac

# ═══ BASH ══════════════════════════════════════════════════════════
elif [ -n "${BASH_VERSION:-}" ]; then

  __sv_fgc() { printf '\001\033[38;2;%sm\002' "$1"; }
  __sv_rst=$'\001\033[0m\002'

  __signal_violet_prompt() {
    local code=$?
    local B U H D G R
    B=$(__sv_fgc "$__sv_violet")
    U=$(__sv_fgc "$__sv_gold")
    H=$(__sv_fgc "$__sv_punct")
    D=$(__sv_fgc "$__sv_gold_mid")
    G=$(__sv_fgc "$__sv_steel_dim")
    R="$__sv_rst"

    local git_part
    git_part=$(__signal_violet_git)
    [ -n "$git_part" ] && git_part="${G}${git_part}${R}"

    local tail_part code_part
    if [ "$code" -ne 0 ]; then
      tail_part="$(__sv_fgc "$__sv_clay")"'\$ '"${R}"
      code_part=" $(__sv_fgc "$__sv_clay")${code}${R}"
    else
      tail_part="$(__sv_fgc "$__sv_gold_pale")"'\$ '"${R}"
      code_part=""
    fi

    PS1="${B}[${R}${U}\u${R}${H}@\h${R} ${D}\W${R}${git_part}${code_part}${B}]${R}${tail_part}"
  }

  case $- in
    *i*)
      case "$PROMPT_COMMAND" in
        *__signal_violet_prompt*) ;;
        '') PROMPT_COMMAND='__signal_violet_prompt' ;;
        *)  PROMPT_COMMAND="__signal_violet_prompt;${PROMPT_COMMAND}" ;;
      esac
      ;;
  esac

fi

# ── ls / eza / fd renkleri ─────────────────────────────────────────
# Dosya turleri editorde token siniflarina karsilik gelen renkleri alir:
# dizin = property, calistirilabilir = function, arsiv = number,
# yapilandirma = keyword, gecici/yedek = gutter.
__sv_ls() {
  printf '%s' \
    "di=38;2;${__sv_steel_dim}:" \
    "ln=38;2;${__sv_violet}:" \
    "or=38;2;${__sv_clay};1:" \
    "ex=38;2;${__sv_gold_pale}:" \
    "so=38;2;${__sv_violet}:" \
    "pi=38;2;${__sv_violet}:" \
    "bd=38;2;${__sv_cream}:" \
    "cd=38;2;${__sv_cream}:" \
    "su=38;2;${__sv_clay}:" \
    "sg=38;2;${__sv_clay}:" \
    "tw=38;2;${__sv_steel_dim}:" \
    "ow=38;2;${__sv_steel_dim}:" \
    "fi=38;2;${__sv_fg}:" \
    "mi=38;2;${__sv_clay}:" \
    "*.tar=38;2;${__sv_cream}:*.tgz=38;2;${__sv_cream}:*.zip=38;2;${__sv_cream}:" \
    "*.gz=38;2;${__sv_cream}:*.xz=38;2;${__sv_cream}:*.zst=38;2;${__sv_cream}:" \
    "*.7z=38;2;${__sv_cream}:*.rar=38;2;${__sv_cream}:*.deb=38;2;${__sv_cream}:" \
    "*.pkg.tar.zst=38;2;${__sv_cream}:" \
    "*.png=38;2;${__sv_gold_mid}:*.jpg=38;2;${__sv_gold_mid}:" \
    "*.jpeg=38;2;${__sv_gold_mid}:*.gif=38;2;${__sv_gold_mid}:" \
    "*.webp=38;2;${__sv_gold_mid}:*.svg=38;2;${__sv_gold_mid}:" \
    "*.mp4=38;2;${__sv_gold_mid}:*.mkv=38;2;${__sv_gold_mid}:" \
    "*.yaml=38;2;${__sv_gold}:*.yml=38;2;${__sv_gold}:" \
    "*.tf=38;2;${__sv_gold}:*.tfvars=38;2;${__sv_gold}:*.hcl=38;2;${__sv_gold}:" \
    "*.toml=38;2;${__sv_gold}:*.json=38;2;${__sv_gold}:*.ini=38;2;${__sv_gold}:" \
    "*.conf=38;2;${__sv_gold}:*.cfg=38;2;${__sv_gold}:" \
    "*Dockerfile=38;2;${__sv_gold}:*.env=38;2;${__sv_gold}:" \
    "*.py=38;2;${__sv_steel}:*.go=38;2;${__sv_steel}:*.rs=38;2;${__sv_steel}:" \
    "*.sh=38;2;${__sv_gold_pale}:*.bash=38;2;${__sv_gold_pale}:" \
    "*.zsh=38;2;${__sv_gold_pale}:" \
    "*.lua=38;2;${__sv_steel}:*.md=38;2;${__sv_fg}:" \
    "*.pem=38;2;${__sv_clay}:*.key=38;2;${__sv_clay}:*.crt=38;2;${__sv_clay}:" \
    "*.log=38;2;${__sv_punct}:*.bak=38;2;${__sv_dim}:*~=38;2;${__sv_dim}:" \
    "*.swp=38;2;${__sv_dim}:*.tmp=38;2;${__sv_dim}:"
}
LS_COLORS="$(__sv_ls)"
export LS_COLORS
export EZA_COLORS="$LS_COLORS"

# zsh'in kendi tamamlama menusu LS_COLORS'i otomatik almaz; baglayalim.
if [ -n "${ZSH_VERSION:-}" ]; then
  zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}" 2>/dev/null
fi

# ── man sayfalari ──────────────────────────────────────────────────
# less'in termcap yeteneklerini eziyoruz; man tek renk olmaktan cikiyor.
export LESS_TERMCAP_md=$'\033[38;2;'"${__sv_gold}"'m'      # kalin  -> keyword
export LESS_TERMCAP_me=$'\033[0m'
export LESS_TERMCAP_us=$'\033[38;2;'"${__sv_steel_dim}"'m' # alti cizili
export LESS_TERMCAP_ue=$'\033[0m'
export LESS_TERMCAP_so=$'\033[48;2;'"${__sv_violet}"'m'$'\033[38;2;0;0;0m'
export LESS_TERMCAP_se=$'\033[0m'
export GROFF_NO_SGR=1
export MANROFFOPT='-P -c'

# ── grep / ripgrep ─────────────────────────────────────────────────
export GREP_COLORS="mt=38;2;${__sv_violet};1:ln=38;2;${__sv_dim}:fn=38;2;${__sv_steel_dim}:se=38;2;${__sv_punct}"

# ── bat / delta ────────────────────────────────────────────────────
# bat'in kendi temasi yok; en yakini ANSI'ye saygi duyani.
export BAT_THEME="ansi"

# ── jq ─────────────────────────────────────────────────────────────
# Alan sirasi: null:false:true:sayilar:stringler:diziler:nesneler:anahtarlar
# Editordeki token siniflariyla ayni: sayi=cream, string=gold_mid,
# yapisal parantezler=punct, anahtar=steel_dim (property rengi).
export JQ_COLORS="0;38;2;${__sv_punct}:0;38;2;${__sv_cream}:0;38;2;${__sv_cream}:0;38;2;${__sv_cream}:0;38;2;${__sv_gold_mid}:0;38;2;${__sv_punct}:0;38;2;${__sv_punct}:0;38;2;${__sv_steel_dim}"

# ── zsh-autosuggestions ────────────────────────────────────────────
# Oneri metni gutter grisi: okunur ama yazdigin komutla karismaz.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737068"
