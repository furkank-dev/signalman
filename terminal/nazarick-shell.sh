# ═══════════════════════════════════════════════════════════════════
#  NAZARICK — kabuk tarafi   (zsh + bash)
#
#  Editor renkli, terminal duz beyazsa tema yarim kalir. Bu dosya
#  paletin ayni degerlerini prompt'a, ls ciktisina, man sayfalarina ve
#  grep eslesmelerine tasir.
#
#  Kurulum — .zshrc icine:
#     [ -f ~/.config/signalman/nazarick-shell.sh ] && . ~/.config/signalman/nazarick-shell.sh
#
#  Not: prompt icin zsh ve bash ayri ayri ele alinir. zsh'ta
#  non-printing diziler %{...%} ile, bash'te \001\002 ile isaretlenir;
#  yanlis olani kullanmak satir sarmasini bozar (uzun komutta imlec kayar).
# ═══════════════════════════════════════════════════════════════════

# ── palet ──────────────────────────────────────────────────────────
# nvim/nazarick.lua ve terminal/nazarick.conf ile ayni degerler.
__nz_violet='224;184;120'  # #E0B878  chrome
__nz_gold='224;184;120'  # #E0B878  keyword
__nz_gold_pale='234;221;189'  # #EADDBD  function
__nz_gold_mid='144;189;164'  # #90BDA4  string
__nz_cream='224;160;125'  # #E0A07D  number
__nz_steel='186;205;225'  # #BACDE1  type
__nz_steel_dim='156;183;183'  # #9CB7B7  property
__nz_fg='208;201;193'  # #D0C9C1  text
__nz_punct='135;127;118'  # #877F76  punctuation
__nz_dim='110;104;96'  # #6E6860  gutter
__nz_clay='255;112;97'  # #FF7061  error
__nz_sage='88;190;108'  # #58BE6C  ok

# ── git durumu (kabuktan bagimsiz) ─────────────────────────────────
__nazarick_git() {
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
  __nz_zc() { printf '%%{\033[38;2;%sm%%}' "$1"; }
  __nz_zrst='%{\033[0m%}'

  __nazarick_prompt() {
    local code=$?
    local B U H D G R
    B=$(__nz_zc "$__nz_violet")      # parantezler
    U=$(__nz_zc "$__nz_gold")        # kullanici
    H=$(__nz_zc "$__nz_punct")       # @makine
    D=$(__nz_zc "$__nz_gold_mid")    # dizin
    G=$(__nz_zc "$__nz_steel_dim")   # git
    R=$(printf '%%{\033[0m%%}')

    local git_part
    git_part=$(__nazarick_git)
    # Dal adinda % gecerse zsh onu prompt kodu sanar; kacisla.
    git_part=${git_part//\%/%%}
    [ -n "$git_part" ] && git_part="${G}${git_part}${R}"

    local tail_part code_part
    if [ "$code" -ne 0 ]; then
      tail_part="$(__nz_zc "$__nz_clay")%(!.#.$)${R} "
      code_part=" $(__nz_zc "$__nz_clay")${code}${R}"
    else
      tail_part="$(__nz_zc "$__nz_gold_pale")%(!.#.$)${R} "
      code_part=""
    fi

    # %n kullanici, %m makine, %1~ bulunulan dizin (bash'teki \W)
    PS1="${B}[${R}${U}%n${R}${H}@%m${R} ${D}%1~${R}${git_part}${code_part}${B}]${R}${tail_part}"
  }

  # precmd_functions = zsh'in PROMPT_COMMAND karsiligi. Ayni fonksiyonu
  # iki kez eklememek icin once kontrol et (dosya tekrar source edilirse).
  typeset -ga precmd_functions
  case " ${precmd_functions[*]} " in
    *" __nazarick_prompt "*) ;;
    *) precmd_functions+=(__nazarick_prompt) ;;
  esac

# ═══ BASH ══════════════════════════════════════════════════════════
elif [ -n "${BASH_VERSION:-}" ]; then

  __nz_fgc() { printf '\001\033[38;2;%sm\002' "$1"; }
  __nz_rst=$'\001\033[0m\002'

  __nazarick_prompt() {
    local code=$?
    local B U H D G R
    B=$(__nz_fgc "$__nz_violet")
    U=$(__nz_fgc "$__nz_gold")
    H=$(__nz_fgc "$__nz_punct")
    D=$(__nz_fgc "$__nz_gold_mid")
    G=$(__nz_fgc "$__nz_steel_dim")
    R="$__nz_rst"

    local git_part
    git_part=$(__nazarick_git)
    [ -n "$git_part" ] && git_part="${G}${git_part}${R}"

    local tail_part code_part
    if [ "$code" -ne 0 ]; then
      tail_part="$(__nz_fgc "$__nz_clay")"'\$ '"${R}"
      code_part=" $(__nz_fgc "$__nz_clay")${code}${R}"
    else
      tail_part="$(__nz_fgc "$__nz_gold_pale")"'\$ '"${R}"
      code_part=""
    fi

    PS1="${B}[${R}${U}\u${R}${H}@\h${R} ${D}\W${R}${git_part}${code_part}${B}]${R}${tail_part}"
  }

  case $- in
    *i*)
      case "$PROMPT_COMMAND" in
        *__nazarick_prompt*) ;;
        '') PROMPT_COMMAND='__nazarick_prompt' ;;
        *)  PROMPT_COMMAND="__nazarick_prompt;${PROMPT_COMMAND}" ;;
      esac
      ;;
  esac

fi

# ── ls / eza / fd renkleri ─────────────────────────────────────────
# Dosya turleri editorde token siniflarina karsilik gelen renkleri alir:
# dizin = property, calistirilabilir = function, arsiv = number,
# yapilandirma = keyword, gecici/yedek = gutter.
__nz_ls() {
  printf '%s' \
    "di=38;2;${__nz_steel_dim}:" \
    "ln=38;2;${__nz_violet}:" \
    "or=38;2;${__nz_clay};1:" \
    "ex=38;2;${__nz_gold_pale}:" \
    "so=38;2;${__nz_violet}:" \
    "pi=38;2;${__nz_violet}:" \
    "bd=38;2;${__nz_cream}:" \
    "cd=38;2;${__nz_cream}:" \
    "su=38;2;${__nz_clay}:" \
    "sg=38;2;${__nz_clay}:" \
    "tw=38;2;${__nz_steel_dim}:" \
    "ow=38;2;${__nz_steel_dim}:" \
    "fi=38;2;${__nz_fg}:" \
    "mi=38;2;${__nz_clay}:" \
    "*.tar=38;2;${__nz_cream}:*.tgz=38;2;${__nz_cream}:*.zip=38;2;${__nz_cream}:" \
    "*.gz=38;2;${__nz_cream}:*.xz=38;2;${__nz_cream}:*.zst=38;2;${__nz_cream}:" \
    "*.7z=38;2;${__nz_cream}:*.rar=38;2;${__nz_cream}:*.deb=38;2;${__nz_cream}:" \
    "*.pkg.tar.zst=38;2;${__nz_cream}:" \
    "*.png=38;2;${__nz_gold_mid}:*.jpg=38;2;${__nz_gold_mid}:" \
    "*.jpeg=38;2;${__nz_gold_mid}:*.gif=38;2;${__nz_gold_mid}:" \
    "*.webp=38;2;${__nz_gold_mid}:*.svg=38;2;${__nz_gold_mid}:" \
    "*.mp4=38;2;${__nz_gold_mid}:*.mkv=38;2;${__nz_gold_mid}:" \
    "*.yaml=38;2;${__nz_gold}:*.yml=38;2;${__nz_gold}:" \
    "*.tf=38;2;${__nz_gold}:*.tfvars=38;2;${__nz_gold}:*.hcl=38;2;${__nz_gold}:" \
    "*.toml=38;2;${__nz_gold}:*.json=38;2;${__nz_gold}:*.ini=38;2;${__nz_gold}:" \
    "*.conf=38;2;${__nz_gold}:*.cfg=38;2;${__nz_gold}:" \
    "*Dockerfile=38;2;${__nz_gold}:*.env=38;2;${__nz_gold}:" \
    "*.py=38;2;${__nz_steel}:*.go=38;2;${__nz_steel}:*.rs=38;2;${__nz_steel}:" \
    "*.sh=38;2;${__nz_gold_pale}:*.bash=38;2;${__nz_gold_pale}:" \
    "*.zsh=38;2;${__nz_gold_pale}:" \
    "*.lua=38;2;${__nz_steel}:*.md=38;2;${__nz_fg}:" \
    "*.pem=38;2;${__nz_clay}:*.key=38;2;${__nz_clay}:*.crt=38;2;${__nz_clay}:" \
    "*.log=38;2;${__nz_punct}:*.bak=38;2;${__nz_dim}:*~=38;2;${__nz_dim}:" \
    "*.swp=38;2;${__nz_dim}:*.tmp=38;2;${__nz_dim}:"
}
LS_COLORS="$(__nz_ls)"
export LS_COLORS
export EZA_COLORS="$LS_COLORS"

# zsh'in kendi tamamlama menusu LS_COLORS'i otomatik almaz; baglayalim.
if [ -n "${ZSH_VERSION:-}" ]; then
  zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}" 2>/dev/null
fi

# ── man sayfalari ──────────────────────────────────────────────────
# less'in termcap yeteneklerini eziyoruz; man tek renk olmaktan cikiyor.
export LESS_TERMCAP_md=$'\033[38;2;'"${__nz_gold}"'m'      # kalin  -> keyword
export LESS_TERMCAP_me=$'\033[0m'
export LESS_TERMCAP_us=$'\033[38;2;'"${__nz_steel_dim}"'m' # alti cizili
export LESS_TERMCAP_ue=$'\033[0m'
export LESS_TERMCAP_so=$'\033[48;2;'"${__nz_violet}"'m'$'\033[38;2;0;0;0m'
export LESS_TERMCAP_se=$'\033[0m'
export GROFF_NO_SGR=1
export MANROFFOPT='-P -c'

# ── grep / ripgrep ─────────────────────────────────────────────────
export GREP_COLORS="mt=38;2;${__nz_violet};1:ln=38;2;${__nz_dim}:fn=38;2;${__nz_steel_dim}:se=38;2;${__nz_punct}"

# ── bat / delta ────────────────────────────────────────────────────
# terminal/nazarick.tmTheme, bat'in tema klasorune kopyalanip
# `bat cache --build` calistirildiysa onu kullan; yoksa ANSI'ye dus.
# bat temayi dosya adindan tanir. delta da BAT_THEME'i okur.
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes/nazarick.tmTheme" ]; then
  export BAT_THEME="nazarick"
else
  export BAT_THEME="ansi"
fi

# ── fzf ────────────────────────────────────────────────────────────
# Eslesme mor, secili satir koyu mor zemin + sari isaretci.
# Kabuk dosyasi tekrar source edilirse ayni renk iki kez eklenmesin.
case "${FZF_DEFAULT_OPTS:-}" in
  *"hl:#E0B878"*) ;;
  *) export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --color=fg:#D0C9C1,bg:-1,hl:#E0B878,fg+:#E9E4DC,bg+:#3C2A0E,hl+:#EADDBD,info:#877F76,prompt:#E0B878,pointer:#EADDBD,marker:#90BDA4,spinner:#E0B878,header:#A89688,border:#2A2319,gutter:-1" ;;
esac

# ── jq ─────────────────────────────────────────────────────────────
# Alan sirasi: null:false:true:sayilar:stringler:diziler:nesneler:anahtarlar
# Editordeki token siniflariyla ayni: sayi=cream, string=gold_mid,
# yapisal parantezler=punct, anahtar=steel_dim (property rengi).
export JQ_COLORS="0;38;2;${__nz_punct}:0;38;2;${__nz_cream}:0;38;2;${__nz_cream}:0;38;2;${__nz_cream}:0;38;2;${__nz_gold_mid}:0;38;2;${__nz_punct}:0;38;2;${__nz_punct}:0;38;2;${__nz_steel_dim}"

# ── zsh-autosuggestions ────────────────────────────────────────────
# Oneri metni gutter grisi: okunur ama yazdigin komutla karismaz.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6E6860"
