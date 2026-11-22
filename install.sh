#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

# ── dry-run flag ──────────────────────────────────────────────────────────────
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    *) printf "Unknown option: %s\n" "$arg"; exit 1 ;;
  esac
done

# ── colours ───────────────────────────────────────────────────────────────────
bold=$(tput bold 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
cyan=$(tput setaf 6 2>/dev/null || true)

# ── helpers ───────────────────────────────────────────────────────────────────
ask() {
  local prompt="$1" default="$2" reply
  printf "%s [%s]: " "$prompt" "$default"
  read -r reply
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy] ]]
}

header() { printf "\n%s==> %s%s\n" "$bold$cyan" "$1" "$reset"; }
ok()     { printf "%s✓ %s%s\n" "$green" "$1" "$reset"; }
skip()   { printf "%s- %s (skipped)%s\n" "$yellow" "$1" "$reset"; }
error()  { printf "%s✗ %s failed — continuing%s\n" "$(tput setaf 1 2>/dev/null || true)" "$1" "$reset"; }
dryrun() { printf "%s[DRY RUN] %s%s\n" "$yellow" "$1" "$reset"; }

symlink() {
  local src="$1" dst="$2"
  if [ "$DRY_RUN" -eq 1 ]; then
    [ -e "$src" ] || { dryrun "MISSING source: $src"; return; }
    dryrun "Would link $dst → $src"
  else
    mkdir -p "$(dirname "$dst")" || return 1
    ln -sf "$src" "$dst" || return 1
    ok "Linked $dst → $src"
  fi
}

# ── component functions ───────────────────────────────────────────────────────
install_homebrew_packages() {
  header "Homebrew packages"
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Visit https://brew.sh to install it first."
    return 1
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    dryrun "Would run: brew bundle --file=$DOTFILES_DIR/Brewfile"
    dryrun "Checking what is missing or outdated:"
    brew bundle check --file="$DOTFILES_DIR/Brewfile" --verbose || true
  else
    brew bundle --file="$DOTFILES_DIR/Brewfile" --verbose
    ok "Homebrew packages installed"
  fi
}

install_zsh() {
  header "Zsh config"
  if [ "$DRY_RUN" -eq 1 ]; then
    [ -f "$HOME/.zshrc" ]           && dryrun "Would backup ~/.zshrc"
    [ -f "$HOME/.zsh_plugins.txt" ] && dryrun "Would backup ~/.zsh_plugins.txt"
  else
    [ -f "$HOME/.zshrc" ]           && cp "$HOME/.zshrc"           "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    [ -f "$HOME/.zsh_plugins.txt" ] && cp "$HOME/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt.backup.$(date +%Y%m%d%H%M%S)"
  fi
  symlink "$DOTFILES_DIR/zsh/zshrc"           "$HOME/.zshrc"
  symlink "$DOTFILES_DIR/zsh/zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
}

install_git() {
  header "Git config"
  symlink "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
}

install_starship() {
  header "Starship prompt"
  if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
  fi
  if [ -f "$DOTFILES_DIR/starship/starship-vscode.toml" ]; then
    symlink "$DOTFILES_DIR/starship/starship-vscode.toml" "$HOME/.config/starship-vscode.toml"
  fi
}

install_ghostty() {
  header "Ghostty config"
  if [ "$DRY_RUN" -eq 1 ]; then
    [ -e "$DOTFILES_DIR/config.ghostty" ] || { dryrun "MISSING source: $DOTFILES_DIR/config.ghostty"; return; }
    dryrun "Would copy config.ghostty → ~/.config/ghostty/config"
  else
    mkdir -p "$HOME/.config/ghostty"
    cp "$DOTFILES_DIR/config.ghostty" "$HOME/.config/ghostty/config"
    ok "Copied config.ghostty → ~/.config/ghostty/config"
  fi
}

install_zed() {
  header "Zed settings and keymap"
  local file src dst backup
  for file in settings.json keymap.json; do
    src="$DOTFILES_DIR/zed/$file"
    dst="$HOME/.config/zed/$file"
    if [[ ! -f "$src" ]]; then
      printf 'Missing Zed file: %s\n' "$src" >&2
      return 1
    fi
    if [[ "$src" -ef "$dst" ]]; then
      ok "Already linked $dst"
      continue
    fi
    if [[ -d "$dst" || ( -e "$dst" && ! -f "$dst" && ! -L "$dst" ) ]]; then
      printf 'Expected a file at %s\n' "$dst" >&2
      return 1
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        dryrun "Would back up $dst before linking"
      else
        backup=$(mktemp "$dst.backup.XXXXXXXX") || return 1
        cp -pP "$dst" "$backup" || return 1
        ok "Saved $backup"
      fi
    fi
    symlink "$src" "$dst" || return 1
  done
}

install_claude() {
  header "Claude Code multi-account"
  local work_dir="$HOME/.claude-work"
  local src="$DOTFILES_DIR/claude/work-settings.json"
  local dst="$work_dir/settings.json"
  if [ "$DRY_RUN" -eq 1 ]; then
    [ -d "$work_dir" ] || dryrun "Would create $work_dir"
    dryrun "Would link $dst → $src"
    dryrun "Note: run 'claude-work' and log in manually with your Team account"
    return
  fi
  mkdir -p "$work_dir"
  ok "Created $work_dir"
  symlink "$src" "$dst"
  printf "%s  → Run 'claude-work' and log in with your Team account%s\n" "$yellow" "$reset"
}

install_latex() {
  header "LaTeX packages"
  if [ "$DRY_RUN" -eq 1 ]; then
    if ! command -v tlmgr >/dev/null 2>&1; then
      dryrun "tlmgr not found — would install BasicTeX via Homebrew first"
    else
      dryrun "Would run: scripts/install-latex.zsh"
    fi
    return
  fi
  if ! command -v tlmgr >/dev/null 2>&1; then
    echo "tlmgr not found — installing BasicTeX via Homebrew..."
    brew install --cask basictex
    eval "$(/usr/libexec/path_helper)"
    if ! command -v tlmgr >/dev/null 2>&1; then
      echo "BasicTeX installed but tlmgr still not in PATH. Try opening a new shell and re-running."
      return 1
    fi
  fi
  zsh "$DOTFILES_DIR/scripts/install-latex.zsh"
}

# ── interactive selection ─────────────────────────────────────────────────────
printf "\n%sDotfiles installer%s" "$bold" "$reset"
[ "$DRY_RUN" -eq 1 ] && printf "%s  [DRY RUN — nothing will be changed]%s" "$yellow" "$reset"
printf "\n"
printf "Choose which components to install:\n\n"

do_brew=0
do_zsh=0
do_git=0
do_starship=0
do_ghostty=0
do_latex=0
do_zed=0
do_claude=0

ask "  Homebrew packages (Brewfile)"  "Y" && do_brew=1
ask "  Zsh config (.zshrc)"           "Y" && do_zsh=1
ask "  Git config (.gitconfig)"       "Y" && do_git=1
ask "  Starship prompt"               "Y" && do_starship=1
ask "  Ghostty config"                "Y" && do_ghostty=1
ask "  LaTeX packages (tlmgr)"        "N" && do_latex=1
ask "  Zed settings and keymap"       "Y" && do_zed=1
ask "  Claude Code multi-account"     "Y" && do_claude=1

# ── summary + confirm ─────────────────────────────────────────────────────────
printf "\n%sSelected components:%s\n" "$bold" "$reset"
any=0
show_component() {
  local flag="$1" label="$2"
  if [ "$flag" -eq 1 ]; then
    printf "  %s✓ %s%s\n" "$green" "$label" "$reset"
    any=1
  else
    printf "  %s- %s%s\n" "$yellow" "$label" "$reset"
  fi
}
show_component "$do_brew"     "Homebrew packages"
show_component "$do_zsh"      "Zsh config"
show_component "$do_git"      "Git config"
show_component "$do_starship" "Starship prompt"
show_component "$do_ghostty"  "Ghostty config"
show_component "$do_latex"    "LaTeX packages"
show_component "$do_zed"      "Zed settings and keymap"
show_component "$do_claude"   "Claude Code multi-account"

if [ "$any" -eq 0 ]; then
  echo "Nothing selected. Exiting."
  exit 0
fi

printf "\n"
if [ "$DRY_RUN" -eq 1 ]; then
  ask "Proceed with dry run?" "Y" || { echo "Aborted."; exit 0; }
else
  ask "Proceed with installation?" "Y" || { echo "Aborted."; exit 0; }
  mkdir -p "$HOME/.config"
fi

# ── run selected components ───────────────────────────────────────────────────
run_if() {
  local flag="$1" fn="$2" label="$3"
  if [ "$flag" -eq 1 ]; then
    $fn || error "$label"
  else
    skip "$label"
  fi
}

run_if "$do_brew"     install_homebrew_packages "Homebrew packages"
run_if "$do_zsh"      install_zsh               "Zsh config"
run_if "$do_git"      install_git               "Git config"
run_if "$do_starship" install_starship           "Starship prompt"
run_if "$do_ghostty"  install_ghostty            "Ghostty config"
run_if "$do_latex"    install_latex              "LaTeX packages"
run_if "$do_zed"      install_zed               "Zed settings and keymap"
run_if "$do_claude"   install_claude            "Claude Code multi-account"

if [ "$DRY_RUN" -eq 1 ]; then
  printf "\n%sDry run complete — no changes were made.%s\n" "$bold$yellow" "$reset"
else
  printf "\n%sDone.%s\n" "$bold$green" "$reset"
  if [ "$do_zsh" -eq 1 ]; then
    echo "Run: exec zsh"
  fi
fi
