# dotfiles

Personal macOS setup for Homebrew packages, Zsh, Antidote plugins, Starship, and Ghostty.

The installer expects this repo to live at `~/dotfiles`.

## Fresh macOS setup

### 1. Update macOS

Open **System Settings** and install all available macOS updates first.

### 2. Install Xcode Command Line Tools

```sh
xcode-select --install
```

If macOS says the tools are already installed, continue.

### 3. Install Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, follow Homebrew's printed instructions to add `brew` to the current shell.
On Apple Silicon Macs this is usually:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Verify Homebrew works:

```sh
brew --version
```

### 4. Set up GitHub access

```sh
brew install gh
gh auth login
```

### 5. Clone this repo

HTTPS:

```sh
git clone https://github.com/detinger/dotfiles.git ~/dotfiles
```

### 6. Run the installer

```sh
cd ~/dotfiles
./install.sh
exec zsh
```

Pass `--dry-run` (or `-n`) to preview what would happen without changing anything:

```sh
./install.sh --dry-run
```

The script is interactive — it asks which components to install before doing anything:

| Component | What it does |
|-----------|--------------|
| Homebrew packages | Installs everything in `Brewfile` (CLI tools, apps, VS Code extensions) |
| Zsh config | Backs up and symlinks `~/.zshrc` and `~/.zsh_plugins.txt` |
| Git config | Symlinks `~/.gitconfig` |
| Starship prompt | Symlinks `~/.config/starship.toml` (and `starship-vscode.toml` if present) |
| Ghostty config | Copies `config.ghostty` to `~/.config/ghostty/config` |
| LaTeX packages | Runs `scripts/install-latex.zsh` to install extra tlmgr packages (requires BasicTeX) |

If a component fails, the script reports the error and continues with the rest.

On first Zsh startup, `zsh/zshrc` builds `~/.zsh_plugins.zsh` from `~/.zsh_plugins.txt` with Antidote.

### 7. Verify the setup

```sh
which brew
which zsh
which starship
brew list antidote
ls -la ~/.zshrc ~/.zsh_plugins.txt ~/.gitconfig ~/.config/starship.toml
```

Expected symlinks:

```text
~/.zshrc -> ~/dotfiles/zsh/zshrc
~/.zsh_plugins.txt -> ~/dotfiles/zsh/zsh_plugins.txt
~/.gitconfig -> ~/dotfiles/git/gitconfig
~/.config/starship.toml -> ~/dotfiles/starship/starship.toml
```

Ghostty config is copied (not symlinked), so edit it directly at `~/.config/ghostty/config`.

## Daily maintenance

Update Homebrew packages and apps:

```sh
brew update && brew upgrade
brew cleanup --prune=all
```

Update this repo after editing files:

```sh
cd ~/dotfiles
git add Brewfile install.sh zsh starship git config.ghostty scripts
git commit -m "Update dotfiles"
git push
```

Regenerate the Brewfile from the current Mac:

```sh
brew bundle dump --force --file ~/dotfiles/Brewfile
```

## Files

- `Brewfile` — Homebrew taps, CLI tools, apps, and VS Code extensions.
- `install.sh` — Interactive bootstrap script.
- `zsh/zshrc` — Main Zsh configuration.
- `zsh/zsh_plugins.txt` — Antidote plugin list.
- `starship/starship.toml` — Starship prompt configuration.
- `git/gitconfig` — Git configuration.
- `config.ghostty` — Ghostty terminal configuration.
- `scripts/install-latex.zsh` — Installs extra LaTeX packages via tlmgr.
