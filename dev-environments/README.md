# Development Environments

This directory contains isolated development environments using Nix Flakes and direnv. Each environment is completely isolated and won't interfere with your system configuration or home-manager setup.

## Quick Start

1. **Setup Requirements** (already configured in your system):
   - ✅ Nix with flakes enabled
   - ✅ direnv installed and configured
   - ✅ nix-direnv for better integration

2. **Create a new project**:
   ```bash
   # Copy a template to your project directory
   cp -r dev-environments/templates/web-dev ~/myproject
   cd ~/myproject
   
   # Allow direnv to activate
   direnv allow
   
   # Start coding! All tools are now available
   node --version
   python --version
   docker --version
   ```

3. **Available Templates**:
   - `web-dev/`: Full-stack web development (Node.js, Python, Docker, etc.)
   - `python-dev/`: Pure Python development environment
   - `rust-dev/`: Rust development environment  
   - `minimal/`: Minimal template for custom environments

## How It Works

- **Isolation**: Each project gets its own environment
- **Automatic Activation**: Environment loads when you `cd` into the directory
- **No Conflicts**: Won't interfere with system packages or home-manager
- **Reproducible**: Same environment on any machine with Nix
- **Fast**: Cached builds and shared dependencies

## Usage Tips

- **Entering a project**: Just `cd` into the directory
- **Leaving a project**: `cd` out and environment unloads automatically
- **Updating dependencies**: Edit `flake.nix` and run `direnv reload`
- **Force reload**: `direnv reload` or `nix flake update`

## Customization

Each template contains:
- `flake.nix`: Defines the development environment
- `.envrc`: Tells direnv to load the flake
- `.gitignore`: Excludes nix and direnv artifacts
- Custom scripts and configuration as needed

Feel free to modify any template to suit your specific needs! 