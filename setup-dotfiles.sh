#!/usr/bin/env bash

# ═══════════════════════════════════════════════════════════════════
# Exegol Dotfiles Setup Script
# ═══════════════════════════════════════════════════════════════════
# This script syncs your personal dotfiles to Exegol's my-resources
# directory so they're available in all Exegol containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source directories (configs in this repo)
CONFIGS_DIR="$SCRIPT_DIR/configs"

# Destination (Exegol my-resources)
EXEGOL_RESOURCES="$HOME/.exegol/my-resources"
EXEGOL_SETUP="$EXEGOL_RESOURCES/setup"
EXEGOL_BIN="$EXEGOL_RESOURCES/bin"

# ───────────────────────────────────────────────────────────────────
# Helper Functions
# ───────────────────────────────────────────────────────────────────

print_header() {
    echo -e "\n${PURPLE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════${NC}\n"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ───────────────────────────────────────────────────────────────────
# Pre-flight Checks
# ───────────────────────────────────────────────────────────────────

check_requirements() {
    print_header "Checking Requirements"

    # Check if Exegol is installed
    if ! command -v exegol &> /dev/null; then
        print_warning "Exegol command not found. Make sure Exegol is installed."
    fi

    # Check if configs directory exists
    if [ ! -d "$CONFIGS_DIR" ]; then
        print_error "Configs directory not found: $CONFIGS_DIR"
        exit 1
    fi

    # Create my-resources directories if needed (with sudo if necessary)
    if [ ! -d "$EXEGOL_SETUP" ]; then
        print_info "Creating Exegol setup directory..."
        sudo mkdir -p "$EXEGOL_SETUP"
        sudo chown -R "$USER:$USER" "$EXEGOL_SETUP" 2>/dev/null || true
    fi

    if [ ! -d "$EXEGOL_BIN" ]; then
        print_info "Creating Exegol bin directory..."
        sudo mkdir -p "$EXEGOL_BIN"
        sudo chown -R "$USER:$USER" "$EXEGOL_BIN" 2>/dev/null || true
    fi

    print_success "All requirements met"
}

# ───────────────────────────────────────────────────────────────────
# Setup Starship Configuration
# ───────────────────────────────────────────────────────────────────

setup_starship() {
    print_header "Setting up Starship Configuration"

    sudo mkdir -p "$EXEGOL_SETUP/starship"

    if [ -f "$CONFIGS_DIR/starship.toml" ]; then
        print_info "Copying starship.toml..."
        sudo cp "$CONFIGS_DIR/starship.toml" "$EXEGOL_SETUP/starship/starship.toml"
        print_success "Starship configuration synced"
    else
        print_warning "starship.toml not found in $CONFIGS_DIR"
    fi
}

# ───────────────────────────────────────────────────────────────────
# Setup Zellij Configuration
# ───────────────────────────────────────────────────────────────────

setup_zellij() {
    print_header "Setting up Zellij Configuration"

    if [ -d "$CONFIGS_DIR/zellij" ]; then
        print_info "Copying Zellij configuration..."
        sudo mkdir -p "$EXEGOL_SETUP/zellij"
        sudo cp -r "$CONFIGS_DIR/zellij/"* "$EXEGOL_SETUP/zellij/"
        print_success "Zellij configuration synced"
    else
        print_warning "Zellij config directory not found in $CONFIGS_DIR"
    fi
}

# ───────────────────────────────────────────────────────────────────
# Setup Custom Zshrc (optional - sourced by Exegol)
# ───────────────────────────────────────────────────────────────────

setup_zsh() {
    print_header "Setting up Zsh Configuration"

    sudo mkdir -p "$EXEGOL_SETUP/zsh"

    if [ -f "$CONFIGS_DIR/zshrc" ]; then
        print_info "Copying custom zshrc..."
        sudo cp "$CONFIGS_DIR/zshrc" "$EXEGOL_SETUP/zsh/zshrc"
        print_success "Zsh configuration synced"
    else
        print_warning "zshrc not found in $CONFIGS_DIR"
    fi
}

# ───────────────────────────────────────────────────────────────────
# Copy load_user_setup.sh Script
# ───────────────────────────────────────────────────────────────────

setup_load_script() {
    print_header "Setting up load_user_setup.sh"

    if [ -f "$CONFIGS_DIR/load_user_setup.sh" ]; then
        print_info "Copying load_user_setup.sh..."
        sudo cp "$CONFIGS_DIR/load_user_setup.sh" "$EXEGOL_SETUP/load_user_setup.sh"
        sudo chmod +x "$EXEGOL_SETUP/load_user_setup.sh"
        print_success "load_user_setup.sh installed"
    else
        print_warning "load_user_setup.sh not found in $CONFIGS_DIR"
    fi
}

# ───────────────────────────────────────────────────────────────────
# Summary
# ───────────────────────────────────────────────────────────────────

show_summary() {
    print_header "Setup Complete!"

    echo -e "${GREEN}Your dotfiles have been synced to Exegol!${NC}\n"
    echo "Configurations synced to: $EXEGOL_SETUP"
    echo ""
    echo "  ✓ Starship (starship.toml)"
    echo "  ✓ Zellij (full config)"
    echo "  ✓ Zsh (custom zshrc)"
    echo "  ✓ load_user_setup.sh (tool installer)"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Start a new Exegol container:"
    echo "     exegol start test-env"
    echo ""
    echo "  2. Run the setup script inside the container:"
    echo "     /opt/my-resources/setup/load_user_setup.sh"
    echo ""
    echo "  3. Restart your shell or run: source ~/.zshrc"
    echo ""
    echo -e "${YELLOW}Note:${NC} The setup script installs tools to /opt/my-resources/bin"
    echo "      which persists across container restarts."
}

# ───────────────────────────────────────────────────────────────────
# Main Execution
# ───────────────────────────────────────────────────────────────────

main() {
    clear
    print_header "Exegol Dotfiles Setup"

    check_requirements
    setup_starship
    setup_zellij
    setup_zsh
    setup_load_script
    show_summary
}

# Run main function
main "$@"
