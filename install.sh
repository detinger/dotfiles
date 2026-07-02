#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

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

symlink() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  ok "Linked $dst → $src"
}

# ── component functions ───────────────────────────────────────────────────────
install_homebrew_packages() {
  header "Homebrew packages"
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Visit https://brew.sh to install it first."
    return 1
  fi
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  ok "Homebrew packages installed"
}

install_zsh() {
  header "Zsh config"
  [ -f "$HOME/.zshrc" ]           && cp "$HOME/.zshrc"           "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
  [ -f "$HOME/.zsh_plugins.txt" ] && cp "$HOME/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt.backup.$(date +%Y%m%d%H%M%S)"
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
  mkdir -p "$HOME/.config/ghostty"
  cp "$DOTFILES_DIR/config.ghostty" "$HOME/.config/ghostty/config"
  ok "Copied config.ghostty → ~/.config/ghostty/config"
}

install_latex() {
  header "LaTeX packages"
  if ! command -v tlmgr >/dev/null 2>&1; then
    echo "BasicTeX/MacTeX (tlmgr) is not installed. Install it via Homebrew (basictex) first."
    return 1
  fi
  zsh "$DOTFILES_DIR/scripts/install-latex.zsh"
}

# ── interactive selection ─────────────────────────────────────────────────────
printf "\n%sDotfiles installer%s\n" "$bold" "$reset"
printf "Choose which components to install:\n\n"

declare -A install_map

ask "  Homebrew packages (Brewfile)"  "Y" && install_map[brew]=1     || install_map[brew]=0
ask "  Zsh config (.zshrc)"           "Y" && install_map[zsh]=1      || install_map[zsh]=0
ask "  Git config (.gitconfig)"       "Y" && install_map[git]=1      || install_map[git]=0
ask "  Starship prompt"               "Y" && install_map[starship]=1  || install_map[starship]=0
ask "  Ghostty config"                "Y" && install_map[ghostty]=1   || install_map[ghostty]=0
ask "  LaTeX packages (tlmgr)"        "N" && install_map[latex]=1    || install_map[latex]=0

# ── summary + confirm ─────────────────────────────────────────────────────────
printf "\n%sSelected components:%s\n" "$bold" "$reset"
labels=(
  "brew:Homebrew packages"
  "zsh:Zsh config"
  "git:Git config"
  "starship:Starship prompt"
  "ghostty:Ghostty config"
  "latex:LaTeX packages"
)
any=0
for entry in "${labels[@]}"; do
  key="${entry%%:*}" label="${entry##*:}"
  if [ "${install_map[$key]}" -eq 1 ]; then
    printf "  %s✓ %s%s\n" "$green" "$label" "$reset"
    any=1
  else
    printf "  %s- %s%s\n" "$yellow" "$label" "$reset"
  fi
done

if [ "$any" -eq 0 ]; then
  echo "Nothing selected. Exiting."
  exit 0
fi

printf "\n"
ask "Proceed with installation?" "Y" || { echo "Aborted."; exit 0; }

mkdir -p "$HOME/.config"

# ── run selected components ───────────────────────────────────────────────────
run_component() {
  local fn="$1" label="$2" key="$3"
  if [ "${install_map[$key]}" -eq 1 ]; then
    $fn || error "$label"
  else
    skip "$label"
  fi
}

run_component install_homebrew_packages "Homebrew packages" brew
run_component install_zsh               "Zsh config"        zsh
run_component install_git               "Git config"        git
run_component install_starship          "Starship prompt"   starship
run_component install_ghostty           "Ghostty config"    ghostty
run_component install_latex             "LaTeX packages"    latex

printf "\n%sDone.%s\n" "$bold$green" "$reset"
[ "${install_map[zsh]}" -eq 1 ] && echo "Run: exec zsh"
