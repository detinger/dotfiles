# dotfiles

Personal macOS setup for Homebrew packages, Zsh, Antidote plugins, and Starship.

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

Use one of these options.

SSH clone:

```sh
ssh-keygen -t ed25519 -C "your-email@example.com"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub
```

Add the copied public key to GitHub:

```text
GitHub -> Settings -> SSH and GPG keys -> New SSH key
```

Then test it:

```sh
ssh -T git@github.com
```

HTTPS clone alternative:

```sh
brew install gh
gh auth login
```

### 5. Clone this repo

SSH:

```sh
git clone git@github.com:detinger/dotfiles.git ~/dotfiles
```

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

The script will:

1. Install packages, apps, and VS Code extensions from `Brewfile`.
2. Create `~/.config` if it does not exist.
3. Back up existing `~/.zshrc` and `~/.zsh_plugins.txt` files with a timestamp suffix.
4. Symlink `~/.zshrc` to `~/dotfiles/zsh/zshrc`.
5. Symlink `~/.zsh_plugins.txt` to `~/dotfiles/zsh/zsh_plugins.txt`.
6. Symlink `~/.config/starship.toml` to `~/dotfiles/starship/starship.toml`.

On first Zsh startup, `zsh/zshrc` builds `~/.zsh_plugins.zsh` from `~/.zsh_plugins.txt` with Antidote.

### 7. Verify the setup

```sh
which brew
which zsh
which starship
brew list antidote
ls -la ~/.zshrc ~/.zsh_plugins.txt ~/.config/starship.toml
```

Expected symlinks:

```text
~/.zshrc -> ~/dotfiles/zsh/zshrc
~/.zsh_plugins.txt -> ~/dotfiles/zsh/zsh_plugins.txt
~/.config/starship.toml -> ~/dotfiles/starship/starship.toml
```

## Daily maintenance

Update Homebrew packages and apps:

```sh
brew update && brew upgrade
brew cleanup
```

Update this repo after editing files:

```sh
cd ~/dotfiles
git status
git add README Brewfile install.sh zsh starship
git commit -m "Update dotfiles"
git push
```

Regenerate the Brewfile from the current Mac:

```sh
cd ~/dotfiles
brew bundle dump --force --file Brewfile
```

## Important files

- `Brewfile`: Homebrew taps, CLI tools, apps, and VS Code extensions.
- `install.sh`: Bootstrap script for packages and symlinks.
- `zsh/zshrc`: Main Zsh configuration.
- `zsh/zsh_plugins.txt`: Antidote plugin list.
- `starship/starship.toml`: Starship prompt configuration.
