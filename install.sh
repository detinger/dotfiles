#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

if ! command -v brew >/dev/null 2>&1; then
  echo "Install Homebrew first: https://brew.sh"
  exit 1
fi

brew bundle --file="$DOTFILES_DIR/Brewfile"

mkdir -p "$HOME/.config"

[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
[ -f "$HOME/.zsh_plugins.txt" ] && cp "$HOME/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt.backup.$(date +%Y%m%d%H%M%S)"

ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh/zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
  ln -sf "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
fi

if [ -f "$DOTFILES_DIR/starship/starship-vscode.toml" ]; then
  ln -sf "$DOTFILES_DIR/starship/starship-vscode.toml" "$HOME/.config/starship-vscode.toml"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/scripts/install-latex.zsh"

echo "Done."
echo "Run: exec zsh"

