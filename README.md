# Signalman

A single-hue amber theme on true black, with violet chrome.

The code axis stays inside one family. Separation is carried by three axes at
once — lightness, chroma, and a deliberately narrow hue range (OKLCh 46–118) —
rather than by lightness alone. That is the difference between 2.1 and 2.2: the
palette looked the same in a screenshot and read very differently at speed.

## What the colours are doing

| Role | Hex | APCA Lc |
|---|---|---|
| Types, classes | `#F2E3C3` | 90.6 |
| Functions | `#F7D856` | 83.8 |
| Regex metacharacters | `#FFC372` | 76.8 |
| Strings | `#C7BE83` | 66.7 |
| Plain text | `#C4B9A7` | 65.3 |
| Numbers, constants | `#FF9E2D` | 62.5 |
| Regex literals | `#D79C80` | 55.9 |
| Operators | `#BF9E71` | 52.6 |
| Properties | `#ADA261` | 51.4 |
| Keywords | `#CD8B18` | 47.1 |
| Comments | `#939A79` | 45.9 |
| Errors | `#F0887B` | 53.8 |
| Chrome (violet) | `#C57AD4` | 46.0 |
| Line numbers | `#737068` | 27.4 |

Plain text is held at chroma 0.028 — the lowest on the code axis — because the
most frequent token on screen should be the calmest thing on it. Keywords and
numbers carry the saturation instead; they are sparse.

Violet appears on the cursor, selection, active line number, search highlight
and tab border. It never enters the code. Line numbers are the one deliberately
low-contrast element: the gutter is chrome, not content, and it is the only
place in the theme where a neutral grey is correct.

## Structural tokens are not one colour

In 2.1, six structural classes — comments, operators, punctuation, line
numbers, parameters and LSP-unresolved names — sat between CIEDE2000 0.47 and
4.15 of each other. Below about 3 the eye cannot separate two colours at
reading speed, so in practice those six rendered as one. In 2.2 the tightest
adjacent pair in the whole palette is 8.28.

Operators were the worst case: `->`, `==`, `|` carry meaning and were dimmer
than the comments around them. They now sit above the plain-text weight.

## Regex is not one block

The body of a regular expression used to be a single flat colour, which is
backwards — inside a pattern the eye is hunting quantifiers and anchors, not
letters. Literal characters now recede to `#D79C80` and metacharacters advance
to `#FFC372`: `* + ? |`, `^ $ .`, character classes, and escape sequences.
Groups take the function colour so nesting is visible.

Neovim uses language-scoped treesitter captures (`@operator.regex` and
friends), so this only applies inside an injected regex — normal code is
untouched. VSCodium uses the TextMate `*.regexp` scopes.

## The ANSI palette is left honest

`terminal.ansiGreen` is green and `terminal.ansiRed` is red, at CIEDE2000 101
apart. This breaks the single-hue rule on purpose: `git diff`, `pytest`, `trivy`
and `semgrep` all signal pass and fail through those two slots, and trading a
hardwired red/green reflex for a learned amber/rust one is a worse deal than a
slightly impure palette. Purity is worth something in the editor and nothing in
a scan report.

## Palettes

The package ships four themes from the same rules (true black, honest ANSI,
measured separation):

| Theme | Code axis | Chrome |
|---|---|---|
| **Signalman** | single amber family | violet |
| **Guardian** | cool steel greys + one yellow accent | violet + yellow |
| **Signal Violet** | the desktop's violet `#C57AD4` for keywords and yellow `#F5C842` for functions; every other role in its own muted hue | violet + yellow |
| **Nazarick** | black, the desktop's candle gold `#E0B878` for keywords, pale cream functions, and one cold accent (steel) for types and builtins; low saturation throughout | gold |

Each theme has the same set of files under `nvim/`, `terminal/` and `themes/`,
named after the theme (`signal-violet.lua`, `signal-violet.conf`, …). Install
any of them exactly as described below, swapping the name. The Neovim check
command follows the theme: `:SignalmanCheck`, `:GuardianCheck`,
`:SignalVioletCheck`, `:NazarickCheck`.

**Signal Violet and Nazarick extras** — files the two older palettes do not have yet
(shown for Signal Violet; Nazarick has the same set under its own name):

- `yazi/signal-violet.yazi/` — a Yazi flavor (UI + code preview). Copy it to
  `~/.config/yazi/flavors/` and set `[flavor] dark = "signal-violet"` in
  `~/.config/yazi/theme.toml`.
- `terminal/signal-violet.tmTheme` — the same token rules as a tmTheme, for
  `bat` and `delta`. Copy it to `$(bat --config-dir)/themes/`, run
  `bat cache --build`; the shell file then sets `BAT_THEME=signal-violet`.
- The shell file also colours `fzf` (`FZF_DEFAULT_OPTS`).

**Making or changing a theme** — Signal Violet is generated from one palette
file, `tools/palettes/signal-violet.toml`. `tools/` holds the pipeline:
`measure.py` (contrast/separation report), `preview.py` (side-by-side HTML),
`build.py` (writes every file above), `install.sh` (installs a theme on this
machine and switches from the previous one) and `release.sh` (tag, `.vsix`,
GitHub release). See [`tools/README.md`](tools/README.md) (Turkish).

```sh
tools/install.sh signal-violet   # from the repo root; installs every target
```

## Install

**VS Code / VSCodium** — install the `.vsix`, then pick Signalman from the
theme picker.

**kitty** — copy `terminal/signalman.conf` next to `kitty.conf` and add
`include signalman.conf` near the top, above any personal colour overrides.

**Neovim** — copy `nvim/signalman.lua` to `lua/signalman.lua`, add a one-line
`colors/signalman.lua` containing `require('signalman').load()`, and copy
`nvim/signalman-lualine.lua` to `lua/lualine/themes/signalman.lua`.

Optional: `nvim/signalman-lualine-sections.lua` goes in `lua/plugins/`. It is a
layout patch, not a colour file — it stops the line:column indicator from
reading as a clock and makes the powerline separators point one way.

**Shell** — source `terminal/signalman-shell.sh` from `~/.bashrc`. This is what
stops the terminal from being the one monochrome surface in an otherwise themed
setup: prompt, `LS_COLORS`, man pages and grep matches all come from the same
palette.

```sh
[ -f ~/.config/signalman/signalman-shell.sh ] && . ~/.config/signalman/signalman-shell.sh
```

## Options (Neovim)

```lua
require('signalman').setup({
  transparent = false,  -- floats, statusline and background stay transparent
  cursorline  = true,   -- faint fill on the cursor line (L* +5.6 over black)
})
```

`:SignalmanCheck` prints the resolved colour and APCA contrast for every major
token group, including the diagnostic groups. Useful when a plugin overrides
something and you want to know rather than guess.

## License

MIT
