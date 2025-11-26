#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

BIN_DIR="/opt/my-resources/bin"
mkdir -p "$BIN_DIR"

# Starship
if [ ! -f "$BIN_DIR/starship" ]; then
    echo -e "${BLUE}[*]${NC} Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir="$BIN_DIR"
else
    echo -e "${YELLOW}[~]${NC} Starship already installed"
fi

# Zellij
if [ ! -f "$BIN_DIR/zellij" ]; then
    echo -e "${BLUE}[*]${NC} Installing Zellij..."
    curl -sL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar -xz -C "$BIN_DIR"
else
    echo -e "${YELLOW}[~]${NC} Zellij already installed"
fi

# eza
if [ ! -f "$BIN_DIR/eza" ]; then
    echo -e "${BLUE}[*]${NC} Installing eza..."
    curl -sL "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz" | tar -xz -C "$BIN_DIR"
else
    echo -e "${YELLOW}[~]${NC} eza already installed"
fi

# bat
if [ ! -f "$BIN_DIR/bat" ]; then
    echo -e "${BLUE}[*]${NC} Installing bat..."
    BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -sL "https://github.com/sharkdp/bat/releases/latest/download/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
    mv "/tmp/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl/bat" "$BIN_DIR/"
else
    echo -e "${YELLOW}[~]${NC} bat already installed"
fi

# fd
if [ ! -f "$BIN_DIR/fd" ]; then
    echo -e "${BLUE}[*]${NC} Installing fd..."
    FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -sL "https://github.com/sharkdp/fd/releases/latest/download/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
    mv "/tmp/fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd" "$BIN_DIR/"
else
    echo -e "${YELLOW}[~]${NC} fd already installed"
fi

# zoxide
if [ ! -f "$BIN_DIR/zoxide" ]; then
    echo -e "${BLUE}[*]${NC} Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir "$BIN_DIR"
else
    echo -e "${YELLOW}[~]${NC} zoxide already installed"
fi

# delta
if [ ! -f "$BIN_DIR/delta" ]; then
    echo -e "${BLUE}[*]${NC} Installing delta..."
    DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -sL "https://github.com/dandavison/delta/releases/latest/download/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
    mv "/tmp/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl/delta" "$BIN_DIR/"
else
    echo -e "${YELLOW}[~]${NC} delta already installed"
fi

chmod +x "$BIN_DIR"/* 2>/dev/null || true

echo -e "${GREEN}[✓]${NC} All tools installed to $BIN_DIR"
