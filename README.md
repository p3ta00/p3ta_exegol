# P3ta Exegol Configuration

Personal Exegol dotfiles and setup scripts for a customized pentesting environment.

## Features

- **Starship prompt** with Catppuccin Mocha theme and Exegol indicator
- **Modern CLI tools**: eza, bat, fd, zoxide, delta, zellij
- **Zellij** terminal multiplexer with auto plugin permissions
- **Shared history** across Zellij panes (syncs on Enter or Ctrl+H)
- **Burp Suite Pro** license persistence
- **Sliver C2** armory extensions persistence (auto-backup on shell exit)

## Scripts Overview

| Script | Where to Run | Purpose |
|--------|--------------|---------|
| `install.sh` | Host | Full installer - copies everything to `~/.exegol/my-resources/` |
| `setup-dotfiles.sh` | Host | Syncs just configs to my-resources |
| `install-tools.sh` | Container | Downloads/installs CLI tools (starship, eza, bat, etc.) |
| `load_user_setup.sh` | Container (auto) | Runs on first container start, calls install-tools.sh |

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/p3ta00/p3ta_exegol.git ~/dev/p3ta_exegol
cd ~/dev/p3ta_exegol
```

### 2. Run the installer

```bash
./install.sh
```

This copies all configs to `~/.exegol/my-resources/`

### 3. Start an Exegol container

```bash
exegol start mybox
```

Everything loads automatically via the zshrc that Exegol sources.

## Directory Structure

```
p3ta_exegol/
├── configs/
│   ├── starship.toml      # Starship prompt config
│   ├── zshrc              # Custom zsh config (auto-sourced by Exegol)
│   └── zellij/            # Zellij config with plugins
├── install.sh             # Full installer (run on host)
├── setup-dotfiles.sh      # Config sync only (run on host)
├── install-tools.sh       # CLI tool installer (run in container)
├── load_user_setup.sh     # First-start setup (runs automatically)
└── README.md
```

## What Gets Installed

| Tool | Description | Alias |
|------|-------------|-------|
| starship | Modern shell prompt | - |
| eza | Modern `ls` replacement | `ls`, `ll`, `la`, `lt` |
| bat | Modern `cat` replacement | `cat`, `catp` |
| fd | Modern `find` replacement | `fd` |
| zoxide | Smarter `cd` command | `z` |
| delta | Better git diffs | `diff` |
| zellij | Terminal multiplexer | `zj` |

All tools install to `/opt/my-resources/bin/` which persists across containers.

## Persistence Features

### Burp Suite Pro
License/config auto-restores from `setup/burp-config/` on new containers.

```bash
burppro    # Launch Burp Suite Pro
```

### Sliver C2
Armory extensions auto-backup on shell exit to `setup/sliver/`.
Restores automatically on new containers.

### History Sharing
ZSH history syncs across Zellij panes:
- Syncs automatically when you press Enter
- Press `Ctrl+H` to manually sync

## Zellij Usage

```bash
zj                        # Start zellij
Ctrl+a then n             # New pane
Ctrl+a then x             # Close pane
Alt+left/right            # Switch panes
Alt+n                     # New pane
Alt+f                     # Toggle floating pane
```

## Updating Configs

After making changes:

```bash
cd ~/dev/p3ta_exegol
./setup-dotfiles.sh       # Sync to my-resources
git add -A && git commit -m "Update configs" && git push
```

New containers will pick up changes automatically.

## Troubleshooting

### Starship not loading
The zshrc should handle this automatically. If not:
```bash
source ~/.zshrc
```

### Tools not found
Run the installer inside the container:
```bash
/opt/my-resources/setup/install-tools.sh
```

### Prompt looks wrong
Make sure you're using a Nerd Font in your terminal.

### Zellij plugins asking for permissions
The config includes `auto_accept_permissions true` - restart zellij if prompted.
