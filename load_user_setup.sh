#!/bin/bash
set -e

# This script runs once on first container startup.
# Most config is handled by zsh/zshrc which is sourced automatically.
# This script only handles one-time setup that can't be in zshrc.

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Install CLI tools if not present (run install-tools.sh)
if [ -f /opt/my-resources/setup/install-tools.sh ]; then
    /opt/my-resources/setup/install-tools.sh
fi

echo -e "${GREEN}[✓]${NC} First-time setup complete!"
