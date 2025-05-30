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
print_status "1. Check for latest configuration updates"
print_status "2. Create necessary symlinks for home-manager modules"
print_status "3. Fix dotfiles path issues (wallpaper, screenshots, etc.)"
print_status "4. Test the NixOS configuration"
print_status "5. Apply the new configuration"
print_status "6. Set up development environment support"
echo

# Ask for confirmation
read -p "Continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled"
    exit 0
fi

print_header "📡 Checking for updates..."

# Check if we have a git repository
if [[ -d ".git" ]]; then
    print_status "Checking git status..."
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "You have uncommitted changes in the repository"
        print_status "Consider running 'git pull' to get the latest updates before deployment"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Deployment cancelled"
            exit 0
        fi
    else
        print_status "Repository is clean"
    fi
else
    print_warning "Not a git repository - make sure you have the latest configuration"
fi

print_header "📁 Verifying module configuration..."

# Check that our custom modules directory exists
MODULES_PATH="users/julisa/modules"

if [[ ! -d "$MODULES_PATH" ]]; then
    print_error "❌ Custom modules directory not found: $MODULES_PATH"
    print_status "This should have been created in the git repository"
    exit 1
fi

if [[ -f "${MODULES_PATH}/default.nix" ]]; then
    print_status "✅ Custom modules configuration found"
else
    print_error "❌ Custom modules default.nix not found"
    exit 1
fi

# Verify dotfiles are present
DOTFILES_MODULES_PATH="users/julisa/dotfiles/home/modules"
if [[ ! -d "$DOTFILES_MODULES_PATH" ]]; then
    print_error "❌ Dotfiles modules directory not found: $DOTFILES_MODULES_PATH"
    print_status "Expected directory structure:"
    print_status "  users/julisa/dotfiles/home/modules/"
    exit 1
else
    print_status "✅ Dotfiles modules directory found"
fi

print_header "🖼️ Setting up dotfiles resources..."

# Fix wallpaper symlink
WALLPAPER_PATH="users/julisa/wallpaper"
DOTFILES_WALLPAPER_PATH="users/julisa/dotfiles/home/wallpaper"

if [[ -L "$WALLPAPER_PATH" ]]; then
    print_status "Removing existing wallpaper symlink: $WALLPAPER_PATH"
    rm "$WALLPAPER_PATH"
elif [[ -d "$WALLPAPER_PATH" ]]; then
    print_warning "Found directory at $WALLPAPER_PATH - backing up to ${WALLPAPER_PATH}.backup"
    mv "$WALLPAPER_PATH" "${WALLPAPER_PATH}.backup"
fi

if [[ -d "$DOTFILES_WALLPAPER_PATH" ]]; then
    print_status "Creating wallpaper symlink: $WALLPAPER_PATH -> $DOTFILES_WALLPAPER_PATH"
    ln -sf dotfiles/home/wallpaper "$WALLPAPER_PATH"
    
    # Verify the wallpaper symlink works
    if [[ -f "${WALLPAPER_PATH}/hello.png" ]]; then
        print_status "✅ Wallpaper symlink created successfully"
    else
        print_error "❌ Wallpaper symlink verification failed"
        exit 1
    fi
else
    print_error "❌ Dotfiles wallpaper directory not found: $DOTFILES_WALLPAPER_PATH"
    exit 1
fi

# Fix screenshots symlink
SCREENSHOTS_PATH="users/julisa/screenshots"
DOTFILES_SCREENSHOTS_PATH="users/julisa/dotfiles/home/screenshots"

if [[ -L "$SCREENSHOTS_PATH" ]]; then
    print_status "Removing existing screenshots symlink: $SCREENSHOTS_PATH"
    rm "$SCREENSHOTS_PATH"
elif [[ -d "$SCREENSHOTS_PATH" ]]; then
    print_warning "Found directory at $SCREENSHOTS_PATH - backing up to ${SCREENSHOTS_PATH}.backup"
    mv "$SCREENSHOTS_PATH" "${SCREENSHOTS_PATH}.backup"
fi

if [[ -d "$DOTFILES_SCREENSHOTS_PATH" ]]; then
    print_status "Creating screenshots symlink: $SCREENSHOTS_PATH -> $DOTFILES_SCREENSHOTS_PATH"
    ln -sf dotfiles/home/screenshots "$SCREENSHOTS_PATH"
    print_status "✅ Screenshots symlink created successfully"
else
    print_warning "Dotfiles screenshots directory not found, creating directory"
    mkdir -p "$DOTFILES_SCREENSHOTS_PATH"
    ln -sf dotfiles/home/screenshots "$SCREENSHOTS_PATH"
    print_status "✅ Screenshots directory and symlink created"
fi

# Create screenshots directory in home if needed
HOME_SCREENSHOTS="/home/julisa/screenshots"
if [[ ! -d "$HOME_SCREENSHOTS" ]]; then
    print_status "Creating screenshots directory in home: $HOME_SCREENSHOTS"
    mkdir -p "$HOME_SCREENSHOTS"
    print_status "✅ Home screenshots directory created"
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
print_status "  🖼️ Fixed dotfiles paths (wallpaper, screenshots)"
print_status "  🔒 Safe git configuration (excludes hardcoded author info)"
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