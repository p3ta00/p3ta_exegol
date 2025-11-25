#!/bin/bash
# Starship setup for Exegol

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

BIN_DIR="/opt/my-resources/bin"
SETUP_DIR="/opt/my-resources/setup"

mkdir -p "$BIN_DIR"
chmod 755 "$BIN_DIR"

# Install Starship
if [ ! -f "$BIN_DIR/starship" ]; then
    echo -e "${BLUE}[*]${NC} Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir="$BIN_DIR"
    echo -e "${GREEN}[✓]${NC} Starship installed"
fi

# Copy starship config
if [ -f "$SETUP_DIR/starship/starship.toml" ]; then
    mkdir -p /root/.config
    cp "$SETUP_DIR/starship/starship.toml" /root/.config/starship.toml
    echo -e "${GREEN}[✓]${NC} Starship config installed"
fi

# Disable Exegol's prompt hook (let Starship handle it)
sed -i 's/add-zsh-hook precmd update_prompt/#add-zsh-hook precmd update_prompt/g' /root/.zshrc

# Remove zsh-z plugin (conflicts with zoxide)
sed -i 's/zsh-z //' /root/.zshrc

# Add starship init after oh-my-zsh (if not already present)
if ! grep -q 'eval "$(starship init zsh)"' /root/.zshrc 2>/dev/null; then
    # Insert starship init right after oh-my-zsh sourcing
    sed -i '/source \$ZSH\/oh-my-zsh.sh/a\  # Starship prompt\n  export PATH="/opt/my-resources/bin:$PATH"\n  export STARSHIP_CONFIG=~/.config/starship.toml\n  eval "$(starship init zsh)"' /root/.zshrc
    echo -e "${GREEN}[✓]${NC} Starship init added to .zshrc"
fi

# Install Zellij
if [ ! -f "$BIN_DIR/zellij" ]; then
    echo -e "${BLUE}[*]${NC} Installing Zellij..."
    curl -sL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar -xz -C "$BIN_DIR"
    chmod +x "$BIN_DIR/zellij"
    echo -e "${GREEN}[✓]${NC} Zellij installed"
fi

# Copy zellij config
if [ -d "$SETUP_DIR/zellij" ]; then
    mkdir -p /root/.config/zellij
    cp -r "$SETUP_DIR/zellij/"* /root/.config/zellij/
    echo -e "${GREEN}[✓]${NC} Zellij config installed"
fi

# Install CLI tools if missing
if [ ! -f "$BIN_DIR/eza" ]; then
    echo -e "${BLUE}[*]${NC} Installing eza..."
    curl -sL "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz" | tar -xz -C "$BIN_DIR"
    chmod +x "$BIN_DIR/eza"
    echo -e "${GREEN}[✓]${NC} eza installed"
fi

if [ ! -f "$BIN_DIR/bat" ]; then
    echo -e "${BLUE}[*]${NC} Installing bat..."
    BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -sL "https://github.com/sharkdp/bat/releases/latest/download/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
    mv "/tmp/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl/bat" "$BIN_DIR/bat"
    rm -rf "/tmp/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl"
    chmod +x "$BIN_DIR/bat"
    echo -e "${GREEN}[✓]${NC} bat installed"
fi

if [ ! -f "$BIN_DIR/fd" ]; then
    echo -e "${BLUE}[*]${NC} Installing fd..."
    FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -sL "https://github.com/sharkdp/fd/releases/latest/download/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
    mv "/tmp/fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd" "$BIN_DIR/fd"
    rm -rf "/tmp/fd-v${FD_VERSION}-x86_64-unknown-linux-musl"
    chmod +x "$BIN_DIR/fd"
    echo -e "${GREEN}[✓]${NC} fd installed"
fi

if [ ! -f "$BIN_DIR/zoxide" ]; then
    echo -e "${BLUE}[*]${NC} Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir "$BIN_DIR"
    echo -e "${GREEN}[✓]${NC} zoxide installed"
fi

if [ ! -f "$BIN_DIR/delta" ]; then
    echo -e "${BLUE}[*]${NC} Installing delta..."
    DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -sL "https://github.com/dandavison/delta/releases/latest/download/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
    mv "/tmp/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl/delta" "$BIN_DIR/delta"
    rm -rf "/tmp/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl"
    chmod +x "$BIN_DIR/delta"
    echo -e "${GREEN}[✓]${NC} delta installed"
fi

# Create bat config (disable pager by default)
mkdir -p /root/.config/bat
cat > /root/.config/bat/config << 'BATCFG'
--paging=never
--style=plain
--theme=Dracula
BATCFG
echo -e "${GREEN}[✓]${NC} bat config installed"

# Add shell integrations (aliases and zoxide init)
if ! grep -q 'eval "$(zoxide init zsh)"' /root/.zshrc 2>/dev/null; then
    cat >> /root/.zshrc << 'EOF'

# CLI tool aliases and integrations
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -a --icons'
alias lt='eza --tree --icons'
alias cat='bat --style=plain --paging=never'
alias catp='bat --style=full --paging=auto'
eval "$(zoxide init zsh)"
EOF
    echo -e "${GREEN}[✓]${NC} CLI tool integrations added to .zshrc"
fi

# Configure git to use delta
git config --global core.pager "delta" 2>/dev/null || true
git config --global interactive.diffFilter "delta --color-only" 2>/dev/null || true
git config --global delta.navigate true 2>/dev/null || true
git config --global delta.line-numbers true 2>/dev/null || true

echo -e "${GREEN}[✓]${NC} Setup complete!"
