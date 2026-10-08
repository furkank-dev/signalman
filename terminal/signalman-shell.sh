# ═══════════════════════════════════════════════════════════════════
#  SIGNALMAN — kabuk tarafi   (zsh + bash)
#
#  Editor kehribar, terminal duz beyazsa tema yarim kalir. Bu dosya
#  paletin ayni degerlerini prompt'a, ls ciktisina, man sayfalarina ve
#  grep eslesmelerine tasir.
#
#  Kurulum — .zshrc icine:
#     [ -f ~/.config/signalman/signalman-shell.sh ] && . ~/.config/signalman/signalman-shell.sh
#
#  Not: prompt icin zsh ve bash ayri ayri ele alinir. zsh'ta
#  non-printing diziler %{...%} ile, bash'te \001\002 ile isaretlenir;
#  yanlis olani kullanmak satir sarmasini bozar (uzun komutta imlec kayar).
# ═══════════════════════════════════════════════════════════════════

# ── palet ──────────────────────────────────────────────────────────
# nvim/signalman.lua ve terminal/signalman.conf ile ayni degerler.
__sm_violet='197;122;212'   # #C57AD4  chrome
__sm_gold='205;139;24'      # #CD8B18  keyword
__sm_gold_pale='247;216;86' # #F7D856  function
__sm_gold_mid='199;190;131' # #C7BE83  string
__sm_cream='255;158;45'     # #FF9E2D  number
__sm_steel='242;227;195'    # #F2E3C3  type
__sm_steel_dim='173;162;97' # #ADA261  property
__sm_fg='196;185;167'       # #C4B9A7  text
__sm_punct='135;126;104'    # #877E68  punctuation
__sm_dim='115;112;104'      # #737068  gutter
__sm_clay='240;136;123'     # #F0887B  error
__sm_sage='88;190;108'      # #58BE6C  ok

# ── git durumu (kabuktan bagimsiz) ─────────────────────────────────
__signalman_git() {
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

# ── ops baglami: sadece aktifken gorunur ───────────────────────────
# Kubernetes context, AWS profili ve varsayilan olmayan Docker context'i.
# Amac: yanlis cluster'a / hesaba komut atmamak. kubectl/docker CALISTIRILMAZ,
# ayar dosyalari okunur: prompt her satirda hizli kalir.
__signalman_ctx() {
  local out="" cfg ctx
  cfg="${KUBECONFIG:-$HOME/.kube/config}"; cfg="${cfg%%:*}"
  if [ -r "$cfg" ]; then
    ctx=$(sed -n 's/^current-context:[[:space:]]*//p' "$cfg" 2>/dev/null | head -n1)
    ctx=${ctx//\"/}; ctx=${ctx//\'/}
    [ -n "$ctx" ] && out="${out} k8s:${ctx}"
  fi
  [ -n "${AWS_PROFILE:-}" ] && out="${out} aws:${AWS_PROFILE}"
  ctx="${DOCKER_CONTEXT:-}"
  if [ -z "$ctx" ] && [ -r "$HOME/.docker/config.json" ]; then
    ctx=$(sed -n 's/.*"currentContext"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$HOME/.docker/config.json" 2>/dev/null | head -n1)
  fi
  [ -n "$ctx" ] && [ "$ctx" != "default" ] && out="${out} docker:${ctx}"
  printf '%s' "$out"
}

# ═══ ZSH ═══════════════════════════════════════════════════════════
if [ -n "${ZSH_VERSION:-}" ]; then

  # %{...%} = "bu diziler ekranda yer kaplamaz". Bash'in \001\002'sinin
  # zsh karsiligi. Atlanirsa uzun komut satirlarinda imlec konumu kayar.
  __sm_zc() { printf '%%{\033[38;2;%sm%%}' "$1"; }
  __sm_zrst='%{\033[0m%}'

  __signalman_prompt() {
    local code=$?
    local B U H D G K R
    B=$(__sm_zc "$__sm_violet")      # parantezler
    U=$(__sm_zc "$__sm_gold")        # kullanici
    H=$(__sm_zc "$__sm_punct")       # @makine
    D=$(__sm_zc "$__sm_gold_mid")    # dizin
    G=$(__sm_zc "$__sm_steel_dim")   # git
    K=$(__sm_zc "$__sm_steel")       # ops baglami (k8s/aws/docker)
    R=$(printf '%%{\033[0m%%}')

    local git_part
    git_part=$(__signalman_git)
    # Dal adinda % gecerse zsh onu prompt kodu sanar; kacisla.
    git_part=${git_part//\%/%%}
    [ -n "$git_part" ] && git_part="${G}${git_part}${R}"

    local ctx_part
    ctx_part=$(__signalman_ctx)
    ctx_part=${ctx_part//\%/%%}
    [ -n "$ctx_part" ] && ctx_part="${K}${ctx_part}${R}"

    local tail_part code_part
    if [ "$code" -ne 0 ]; then
      tail_part="$(__sm_zc "$__sm_clay")%(!.#.$)${R} "
      code_part=" $(__sm_zc "$__sm_clay")${code}${R}"
    else
      tail_part="$(__sm_zc "$__sm_gold_pale")%(!.#.$)${R} "
      code_part=""
    fi

    # %n kullanici, %m makine, %1~ bulunulan dizin (bash'teki \W)
    PS1="${B}[${R}${U}%n${R}${H}@%m${R} ${D}%1~${R}${ctx_part}${git_part}${code_part}${B}]${R}${tail_part}"
  }

  # precmd_functions = zsh'in PROMPT_COMMAND karsiligi. Ayni fonksiyonu
  # iki kez eklememek icin once kontrol et (dosya tekrar source edilirse).
  typeset -ga precmd_functions
  case " ${precmd_functions[*]} " in
    *" __signalman_prompt "*) ;;
    *) precmd_functions+=(__signalman_prompt) ;;
  esac

# ═══ BASH ══════════════════════════════════════════════════════════
elif [ -n "${BASH_VERSION:-}" ]; then

  __sm_fgc() { printf '\001\033[38;2;%sm\002' "$1"; }
  __sm_rst=$'\001\033[0m\002'

  __signalman_prompt() {
    local code=$?
    local B U H D G K R
    B=$(__sm_fgc "$__sm_violet")
    U=$(__sm_fgc "$__sm_gold")
    H=$(__sm_fgc "$__sm_punct")
    D=$(__sm_fgc "$__sm_gold_mid")
    G=$(__sm_fgc "$__sm_steel_dim")
    K=$(__sm_fgc "$__sm_steel")
    R="$__sm_rst"

    local git_part
    git_part=$(__signalman_git)
    [ -n "$git_part" ] && git_part="${G}${git_part}${R}"

    local ctx_part
    ctx_part=$(__signalman_ctx)
    [ -n "$ctx_part" ] && ctx_part="${K}${ctx_part}${R}"

    local tail_part code_part
    if [ "$code" -ne 0 ]; then
      tail_part="$(__sm_fgc "$__sm_clay")"'\$ '"${R}"
      code_part=" $(__sm_fgc "$__sm_clay")${code}${R}"
    else
      tail_part="$(__sm_fgc "$__sm_gold_pale")"'\$ '"${R}"
      code_part=""
    fi

    PS1="${B}[${R}${U}\u${R}${H}@\h${R} ${D}\W${R}${ctx_part}${git_part}${code_part}${B}]${R}${tail_part}"
  }

  case $- in
    *i*)
      case "$PROMPT_COMMAND" in
        *__signalman_prompt*) ;;
        '') PROMPT_COMMAND='__signalman_prompt' ;;
        *)  PROMPT_COMMAND="__signalman_prompt;${PROMPT_COMMAND}" ;;
      esac
      ;;
  esac

fi

# ── ls / eza / fd renkleri ─────────────────────────────────────────
# Dosya turleri editorde token siniflarina karsilik gelen renkleri alir:
# dizin = property, calistirilabilir = function, arsiv = number,
# yapilandirma = keyword, gecici/yedek = gutter.
__sm_ls() {
  printf '%s' \
    "di=38;2;${__sm_steel_dim}:" \
    "ln=38;2;${__sm_violet}:" \
    "or=38;2;${__sm_clay};1:" \
    "ex=38;2;${__sm_gold_pale}:" \
    "so=38;2;${__sm_violet}:" \
    "pi=38;2;${__sm_violet}:" \
    "bd=38;2;${__sm_cream}:" \
    "cd=38;2;${__sm_cream}:" \
    "su=38;2;${__sm_clay}:" \
    "sg=38;2;${__sm_clay}:" \
    "tw=38;2;${__sm_steel_dim}:" \
    "ow=38;2;${__sm_steel_dim}:" \
    "fi=38;2;${__sm_fg}:" \
    "mi=38;2;${__sm_clay}:" \
    "*.tar=38;2;${__sm_cream}:*.tgz=38;2;${__sm_cream}:*.zip=38;2;${__sm_cream}:" \
    "*.gz=38;2;${__sm_cream}:*.xz=38;2;${__sm_cream}:*.zst=38;2;${__sm_cream}:" \
    "*.7z=38;2;${__sm_cream}:*.rar=38;2;${__sm_cream}:*.deb=38;2;${__sm_cream}:" \
    "*.pkg.tar.zst=38;2;${__sm_cream}:" \
    "*.png=38;2;${__sm_gold_mid}:*.jpg=38;2;${__sm_gold_mid}:" \
    "*.jpeg=38;2;${__sm_gold_mid}:*.gif=38;2;${__sm_gold_mid}:" \
    "*.webp=38;2;${__sm_gold_mid}:*.svg=38;2;${__sm_gold_mid}:" \
    "*.mp4=38;2;${__sm_gold_mid}:*.mkv=38;2;${__sm_gold_mid}:" \
    "*.yaml=38;2;${__sm_gold}:*.yml=38;2;${__sm_gold}:" \
    "*.tf=38;2;${__sm_gold}:*.tfvars=38;2;${__sm_gold}:*.hcl=38;2;${__sm_gold}:" \
    "*.toml=38;2;${__sm_gold}:*.json=38;2;${__sm_gold}:*.ini=38;2;${__sm_gold}:" \
    "*.conf=38;2;${__sm_gold}:*.cfg=38;2;${__sm_gold}:" \
    "*Dockerfile=38;2;${__sm_gold}:*.env=38;2;${__sm_gold}:" \
    "*.py=38;2;${__sm_steel}:*.go=38;2;${__sm_steel}:*.rs=38;2;${__sm_steel}:" \
    "*.sh=38;2;${__sm_gold_pale}:*.bash=38;2;${__sm_gold_pale}:" \
    "*.zsh=38;2;${__sm_gold_pale}:" \
    "*.lua=38;2;${__sm_steel}:*.md=38;2;${__sm_fg}:" \
    "*.pem=38;2;${__sm_clay}:*.key=38;2;${__sm_clay}:*.crt=38;2;${__sm_clay}:" \
    "*.log=38;2;${__sm_punct}:*.bak=38;2;${__sm_dim}:*~=38;2;${__sm_dim}:" \
    "*.swp=38;2;${__sm_dim}:*.tmp=38;2;${__sm_dim}:"
}
LS_COLORS="$(__sm_ls)"
export LS_COLORS
export EZA_COLORS="$LS_COLORS"

# zsh'in kendi tamamlama menusu LS_COLORS'i otomatik almaz; baglayalim.
if [ -n "${ZSH_VERSION:-}" ]; then
  zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}" 2>/dev/null
fi

# ── man sayfalari ──────────────────────────────────────────────────
# less'in termcap yeteneklerini eziyoruz; man tek renk olmaktan cikiyor.
export LESS_TERMCAP_md=$'\033[38;2;'"${__sm_gold}"'m'      # kalin  -> keyword
export LESS_TERMCAP_me=$'\033[0m'
export LESS_TERMCAP_us=$'\033[38;2;'"${__sm_steel_dim}"'m' # alti cizili
export LESS_TERMCAP_ue=$'\033[0m'
export LESS_TERMCAP_so=$'\033[48;2;'"${__sm_violet}"'m'$'\033[38;2;0;0;0m'
export LESS_TERMCAP_se=$'\033[0m'
export GROFF_NO_SGR=1
export MANROFFOPT='-P -c'

# ── grep / ripgrep ─────────────────────────────────────────────────
export GREP_COLORS="mt=38;2;${__sm_violet};1:ln=38;2;${__sm_dim}:fn=38;2;${__sm_steel_dim}:se=38;2;${__sm_punct}"

# ── bat / delta ────────────────────────────────────────────────────
# bat'in kendi temasi yok; en yakini ANSI'ye saygi duyani.
export BAT_THEME="ansi"

# ── jq ─────────────────────────────────────────────────────────────
# Alan sirasi: null:false:true:sayilar:stringler:diziler:nesneler:anahtarlar
# Editordeki token siniflariyla ayni: sayi=cream, string=gold_mid,
# yapisal parantezler=punct, anahtar=steel_dim (property rengi).
export JQ_COLORS="0;38;2;${__sm_punct}:0;38;2;${__sm_cream}:0;38;2;${__sm_cream}:0;38;2;${__sm_cream}:0;38;2;${__sm_gold_mid}:0;38;2;${__sm_punct}:0;38;2;${__sm_punct}:0;38;2;${__sm_steel_dim}"

# ── zsh-autosuggestions ────────────────────────────────────────────
# Oneri metni gutter grisi: okunur ama yazdigin komutla karismaz.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737068"
