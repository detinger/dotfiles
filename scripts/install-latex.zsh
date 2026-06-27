#!/usr/bin/env zsh
# install-latex.zsh
# Installs and updates commonly required TeX Live packages for academic writing.

set -euo pipefail

if ! command -v tlmgr >/dev/null 2>&1; then
  echo "❌ BasicTeX/MacTeX (tlmgr) is not installed."
  exit 1
fi

echo "→ Updating TeX Live manager..."
sudo tlmgr update --self
sudo tlmgr update --all

packages=(
  els-cas-templates
  makecell
  multirow
  sttools
)

echo "→ Installing required packages..."
sudo tlmgr install "${packages[@]}"

echo
echo "✓ Verifying installation..."
kpsewhich cas-sc.cls
kpsewhich makecell.sty
kpsewhich multirow.sty
kpsewhich stfloats.sty

echo
echo "✅ LaTeX environment is ready."
