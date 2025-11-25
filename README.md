# P3ta Exegol Configuration

Personal Exegol dotfiles and setup scripts for a customized pentesting environment.

## Features

- **Starship prompt** with Catppuccin Mocha theme and Exegol indicator
- **Modern CLI tools**: eza, bat, fd, zoxide, delta
- **Zellij** terminal multiplexer with custom config
- **Shared environment variables** across Zellij panes

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/yourusername/p3ta_exegol.git ~/dev/p3ta_exegol
cd ~/dev/p3ta_exegol
```

### 2. Sync configs to Exegol my-resources

```bash
./setup-dotfiles.sh
```

This copies configs to `~/.exegol/my-resources/setup/`

### 3. Start an Exegol container

```bash
exegol start mybox
```

### 4. Run the setup script (first time only)

Inside the container:

```bash
/opt/my-resources/setup/load_user_setup.sh
source ~/.zshrc
```

## Directory Structure

```
p3ta_exegol/
├── configs/
│   ├── starship.toml       # Starship prompt config
│   ├── zshrc               # Custom zsh config (sourced by Exegol)
│   ├── load_user_setup.sh  # Tool installer script
│   └── zellij/             # Zellij terminal multiplexer config
├── setup-dotfiles.sh       # Syncs configs to ~/.exegol/my-resources
├── load_user_setup.sh      # Copy of tool installer
└── README.md
```

## What Gets Installed

The `load_user_setup.sh` script installs:

| Tool | Description |
|------|-------------|
| starship | Modern shell prompt |
| eza | Modern `ls` replacement |
| bat | Modern `cat` replacement |
| fd | Modern `find` replacement |
| zoxide | Smarter `cd` command |
| delta | Better git diffs |
| zellij | Terminal multiplexer |

All tools are installed to `/opt/my-resources/bin/` which persists across container restarts.

## Custom Aliases

```bash
ls    # eza --icons
ll    # eza -la --icons
la    # eza -a --icons
lt    # eza --tree --icons
cat   # bat --style=plain
catn  # bat (with line numbers)
```

## Zellij Usage

```bash
zellij                    # Start zellij
zellij attach             # Attach to existing session
Ctrl+p n                  # New pane
Ctrl+p x                  # Close pane
Ctrl+t n                  # New tab
```

## Shared Environment Variables

Share variables across Zellij panes (defined in configs/zshrc):

```bash
setshared IP=10.10.10.1   # Set and share
loadshared                # Load in other panes
listshared                # List all shared vars
clearshared               # Clear all

# Shortcuts
setip 10.10.10.1
settarget dc01.domain.com
setdomain domain.com
```

## Updating Configs

After making changes to configs:

```bash
cd ~/dev/p3ta_exegol
./setup-dotfiles.sh
```

Then restart your Exegol container or re-run the setup script.

## Troubleshooting

### Starship not loading
Run inside container:
```bash
/opt/my-resources/setup/load_user_setup.sh
source ~/.zshrc
```

### Tools not in PATH
Add to your shell:
```bash
export PATH="/opt/my-resources/bin:$PATH"
```

### Prompt looks wrong
Make sure you're using a Nerd Font in your terminal.
