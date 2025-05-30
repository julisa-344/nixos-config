#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if running on NixOS
if [[ ! -f /etc/nixos/configuration.nix ]]; then
    print_error "This script must be run on a NixOS system"
    exit 1
fi

# Check if we're in the right directory
if [[ ! -f "configuration.nix" ]]; then
    print_error "Please run this script from the nixos-config directory"
    print_status "Expected to find configuration.nix in current directory"
    exit 1
fi

# Check if running as correct user
EXPECTED_USER="julisa"
CURRENT_USER=$(whoami)

if [[ "$CURRENT_USER" != "$EXPECTED_USER" ]] && [[ "$CURRENT_USER" != "root" ]]; then
    print_warning "This script is designed for user '$EXPECTED_USER'"
    print_warning "Current user: '$CURRENT_USER'"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled"
        exit 0
    fi
fi

print_header "🚀 NixOS Configuration Deployment Script"
print_status "This script will:"
print_status "1. Create necessary symlinks for home-manager modules"
print_status "2. Test the NixOS configuration"
print_status "3. Apply the new configuration"
print_status "4. Set up development environment support"
echo

# Ask for confirmation
read -p "Continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled"
    exit 0
fi

print_header "📁 Setting up module symlinks..."

# Create the modules symlink if it doesn't exist or is broken
MODULES_PATH="users/julisa/modules"
DOTFILES_MODULES_PATH="users/julisa/dotfiles/home/modules"

if [[ -L "$MODULES_PATH" ]]; then
    print_status "Removing existing symlink: $MODULES_PATH"
    rm "$MODULES_PATH"
elif [[ -d "$MODULES_PATH" ]]; then
    print_warning "Found directory at $MODULES_PATH - backing up to ${MODULES_PATH}.backup"
    mv "$MODULES_PATH" "${MODULES_PATH}.backup"
fi

if [[ -d "$DOTFILES_MODULES_PATH" ]]; then
    print_status "Creating symlink: $MODULES_PATH -> $DOTFILES_MODULES_PATH"
    ln -sf dotfiles/home/modules "$MODULES_PATH"
    
    # Verify the symlink works
    if [[ -f "${MODULES_PATH}/default.nix" ]]; then
        print_status "✅ Symlink created successfully"
    else
        print_error "❌ Symlink verification failed"
        exit 1
    fi
else
    print_error "❌ Dotfiles modules directory not found: $DOTFILES_MODULES_PATH"
    print_status "Expected directory structure:"
    print_status "  users/julisa/dotfiles/home/modules/"
    exit 1
fi

print_header "🔧 Testing NixOS configuration..."

# Test the configuration first
print_status "Building configuration (test run)..."
if sudo nixos-rebuild build --show-trace; then
    print_status "✅ Configuration build successful"
else
    print_error "❌ Configuration build failed"
    print_status "Please check the error messages above and fix any issues"
    exit 1
fi

print_header "🎯 Applying NixOS configuration..."

# Apply the configuration
print_status "Switching to new configuration..."
if sudo nixos-rebuild switch --show-trace; then
    print_status "✅ NixOS configuration applied successfully"
else
    print_error "❌ Failed to apply configuration"
    print_status "Your system should still be in a working state"
    print_status "Check the error messages above to diagnose the issue"
    exit 1
fi

print_header "🏠 Verifying Home Manager..."

# Check if home-manager is working
print_status "Checking Home Manager status..."
if command -v home-manager >/dev/null 2>&1; then
    print_status "✅ Home Manager is available"
else
    print_warning "Home Manager command not found in PATH"
    print_status "This is normal if using Home Manager as a NixOS module"
fi

print_header "🛠️ Setting up development environment tools..."

# Check if essential tools are available
print_status "Verifying development tools..."

tools_to_check=("nix" "direnv" "git")
all_good=true

for tool in "${tools_to_check[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        print_status "✅ $tool is available"
    else
        print_warning "❌ $tool not found"
        all_good=false
    fi
done

if [[ "$all_good" == "true" ]]; then
    print_status "✅ All essential development tools are available"
else
    print_warning "Some tools are missing - you may need to log out and back in"
fi

# Make the development environment setup script executable
DEV_SCRIPT="dev-environments/setup-project.sh"
if [[ -f "$DEV_SCRIPT" ]]; then
    chmod +x "$DEV_SCRIPT"
    print_status "✅ Development environment script is ready"
else
    print_warning "Development environment script not found: $DEV_SCRIPT"
fi

print_header "✅ Deployment Complete!"
echo
print_status "Your NixOS system has been successfully updated with:"
print_status "  🔧 Enhanced Nix configuration with flakes support"
print_status "  🏠 Updated Home Manager configuration"
print_status "  🐳 Docker support (rootless)"
print_status "  📁 Development environment templates"
echo

print_header "🚀 Next Steps:"
print_status "1. Log out and log back in to ensure all environment changes take effect"
print_status "2. Test direnv integration:"
print_status "   eval \"\$(direnv hook \$(basename \$SHELL))\""
print_status "3. Create your first development project:"
print_status "   cd ~/nixos-config"
print_status "   ./dev-environments/setup-project.sh my-first-project"
print_status "4. Read the documentation:"
print_status "   cat dev-environments/README.md"
print_status "   cat dev-environments/USAGE.md"
echo

print_status "🎉 Happy coding!"

# Optional: Show system info
echo
print_header "📊 System Information:"
print_status "NixOS version: $(nixos-version 2>/dev/null || echo 'Unknown')"
print_status "Nix version: $(nix --version 2>/dev/null || echo 'Unknown')"
print_status "Current user: $(whoami)"
print_status "Home directory: $HOME"
echo

# Final reminder
print_warning "Remember to restart your shell or log out/in for all changes to take effect!" 