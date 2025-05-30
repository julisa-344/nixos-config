# Development Environment Usage Guide

## Quick Start

### Option 1: Use the Setup Script (Recommended)
```bash
# From your nixos-config directory
./dev-environments/setup-project.sh my-awesome-project

# Or specify a template
./dev-environments/setup-project.sh -t python-dev my-python-app

# Or specify a custom location
./dev-environments/setup-project.sh -d ~/Code my-web-app
```

### Option 2: Manual Setup
```bash
# Copy a template to your desired location
cp -r dev-environments/templates/web-dev ~/myproject
cd ~/myproject

# Allow direnv to activate
direnv allow

# Start coding!
```

## Available Templates

### 🌐 web-dev
**Full-stack web development environment**

Includes: Node.js, Python, Docker, PostgreSQL, Redis, VS Code, Alacritty, and many development tools.

Best for: Web applications, APIs, full-stack development

```bash
./dev-environments/setup-project.sh -t web-dev my-web-app
```

### 🐍 python-dev
**Python development environment**

Includes: Python 3.11, Poetry, Jupyter, data science libraries, testing tools, and documentation generators.

Best for: Python applications, data science, machine learning

```bash
./dev-environments/setup-project.sh -t python-dev my-python-project
```

### ⚡ minimal
**Minimal template for custom environments**

Includes: Basic tools (git, curl, neovim) with extensive comments for customization.

Best for: Custom environments, learning Nix, specific tool requirements

```bash
./dev-environments/setup-project.sh -t minimal my-custom-env
```

## How It Works

1. **Enter directory** → Environment automatically loads
2. **Exit directory** → Environment automatically unloads  
3. **No conflicts** → Each project is completely isolated
4. **Reproducible** → Same environment on any machine with Nix

## Common Commands

```bash
# Create new project
./dev-environments/setup-project.sh my-project

# Allow environment (after copying template)
direnv allow

# Reload environment (after changing flake.nix)
direnv reload

# Force environment refresh
nix flake update && direnv reload

# Check what's available
which python  # Check if tool is available
echo $PATH    # See what's in your PATH
```

## Environment-Specific Help

Each template provides helpful commands:

- **web-dev**: Run `dev-help` for web development commands
- **python-dev**: Run `py-help` for Python development commands
- **minimal**: Edit `flake.nix` to customize

## Customization

### Adding New Tools
Edit `flake.nix` in your project:

```nix
buildInputs = with pkgs; [
  # existing tools...
  
  # Add new tools:
  rustc       # Rust compiler
  go          # Go language
  postgresql  # PostgreSQL
  # Find more at: https://search.nixos.org/packages
];
```

### Adding Environment Variables
Edit `.envrc` in your project:

```bash
export MY_VARIABLE="value"
export API_URL="http://localhost:3000"
```

### Adding Shell Commands
Edit the `shellHook` in `flake.nix`:

```nix
shellHook = ''
  echo "Welcome to my project!"
  
  # Add custom aliases
  alias deploy="./scripts/deploy.sh"
  
  # Add custom functions
  function test-all() {
    pytest && npm test
  }
'';
```

## Troubleshooting

### Environment not loading
```bash
# Check if direnv is working
direnv status

# Allow the environment
direnv allow

# Check for errors
direnv reload
```

### Tools not found
```bash
# Check if in correct directory
pwd

# Check environment status
echo $DEV_ENV

# Reload environment
direnv reload
```

### Slow startup
First run is slow (downloads packages). Subsequent runs are fast due to caching.

### Permission denied
```bash
# Check if .envrc exists and is correct
cat .envrc

# Re-allow direnv
direnv allow
```

## Advanced Usage

### Using Multiple Environments
Each project directory can have its own environment. You can have multiple projects with different tool versions without conflicts.

### Sharing Environments
Commit `flake.nix` and `.envrc` to your project repository. Anyone with Nix can get the exact same environment.

### Pinning Package Versions
Edit `flake.nix` to pin to specific nixpkgs commits for reproducibility across time.

## Best Practices

1. **Start with templates** - Customize as needed
2. **Commit environment files** - Share with your team  
3. **Use meaningful project names** - Easy to identify
4. **Clean up unused projects** - Remove directories you no longer need
5. **Update regularly** - Run `nix flake update` occasionally

## Getting Help

- 📚 [Nix Manual](https://nixos.org/manual/nix/stable/)
- 🔍 [Package Search](https://search.nixos.org/packages)
- 💬 [NixOS Discourse](https://discourse.nixos.org/)
- 📖 [Direnv Documentation](https://direnv.net/)

---

Happy coding! 🚀 