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

# Help function
show_help() {
    cat << EOF
🚀 Development Environment Setup Script

Usage: $0 [OPTIONS] PROJECT_NAME

This script creates a new development project with a Nix flake environment.

OPTIONS:
    -t, --template TEMPLATE    Choose template: web-dev, python-dev, minimal (default: web-dev)
    -d, --directory DIR        Target directory (default: current directory)
    -h, --help                Show this help message

EXAMPLES:
    $0 my-web-app                          # Create web-dev project in ./my-web-app
    $0 -t python-dev my-python-project     # Create python project
    $0 -t minimal -d ~/projects my-tool    # Create minimal project in ~/projects/my-tool

AVAILABLE TEMPLATES:
    web-dev      Full-stack web development (Node.js, Python, Docker, etc.)
    python-dev   Python development environment with data science tools
    minimal      Minimal template for custom development environments

EOF
}

# Default values
TEMPLATE="web-dev"
TARGET_DIR=""
PROJECT_NAME=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--template)
            TEMPLATE="$2"
            shift 2
            ;;
        -d|--directory)
            TARGET_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            print_error "Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$PROJECT_NAME" ]]; then
                PROJECT_NAME="$1"
            else
                print_error "Too many arguments"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate inputs
if [[ -z "$PROJECT_NAME" ]]; then
    print_error "Project name is required"
    show_help
    exit 1
fi

# Validate template
if [[ ! -d "$SCRIPT_DIR/templates/$TEMPLATE" ]]; then
    print_error "Template '$TEMPLATE' not found"
    print_status "Available templates:"
    ls -1 "$SCRIPT_DIR/templates/" | sed 's/^/  - /'
    exit 1
fi

# Set target directory
if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="$(pwd)"
fi

PROJECT_PATH="$TARGET_DIR/$PROJECT_NAME"

# Check if target directory already exists
if [[ -d "$PROJECT_PATH" ]]; then
    print_error "Directory '$PROJECT_PATH' already exists"
    exit 1
fi

# Start setup
print_header "🚀 Setting up development environment..."
print_status "Project name: $PROJECT_NAME"
print_status "Template: $TEMPLATE"
print_status "Target directory: $PROJECT_PATH"
echo

# Create project directory
print_status "Creating project directory..."
mkdir -p "$PROJECT_PATH"

# Copy template files
print_status "Copying template files..."
cp -r "$SCRIPT_DIR/templates/$TEMPLATE/"* "$PROJECT_PATH/"

# Make sure .envrc exists
if [[ ! -f "$PROJECT_PATH/.envrc" ]]; then
    cat > "$PROJECT_PATH/.envrc" << EOF
# This file tells direnv to load our Nix flake environment
use flake

# Add your project-specific environment variables here
export PROJECT_NAME="$PROJECT_NAME"
EOF
fi

# Update project name in .envrc
if grep -q "PROJECT_NAME=" "$PROJECT_PATH/.envrc"; then
    sed -i "s/PROJECT_NAME=\".*\"/PROJECT_NAME=\"$PROJECT_NAME\"/" "$PROJECT_PATH/.envrc"
fi

# Create basic project structure
print_status "Creating project structure..."
mkdir -p "$PROJECT_PATH/src"
mkdir -p "$PROJECT_PATH/tests"
mkdir -p "$PROJECT_PATH/docs"

# Create a basic README
cat > "$PROJECT_PATH/README.md" << EOF
# $PROJECT_NAME

Development environment: $TEMPLATE

## Getting Started

1. **Enter the project directory**:
   \`\`\`bash
   cd $PROJECT_NAME
   \`\`\`

2. **Allow direnv** (you'll be prompted automatically):
   \`\`\`bash
   direnv allow
   \`\`\`

3. **Start developing!** All tools are now available in your PATH.

## Development Environment

This project uses Nix flakes with direnv for reproducible development environments.

- **Automatic activation**: Environment loads when you enter the directory
- **Isolation**: No conflicts with system packages or other projects
- **Reproducible**: Same environment on any machine with Nix

## Available Tools

The environment includes all tools defined in \`flake.nix\`. 
Run the environment-specific help command for more details:

EOF

# Add template-specific help commands to README
case $TEMPLATE in
    web-dev)
        echo "- Run \`dev-help\` for web development commands" >> "$PROJECT_PATH/README.md"
        ;;
    python-dev)
        echo "- Run \`py-help\` for Python development commands" >> "$PROJECT_PATH/README.md"
        ;;
    minimal)
        echo "- Customize \`flake.nix\` to add more tools" >> "$PROJECT_PATH/README.md"
        ;;
esac

cat >> "$PROJECT_PATH/README.md" << EOF

## Customization

Edit \`flake.nix\` to add or remove development tools.
Run \`direnv reload\` after making changes.

For available packages, see: https://search.nixos.org/packages

EOF

# Check if direnv is available
if ! command -v direnv >/dev/null 2>&1; then
    print_warning "direnv is not installed or not in PATH"
    print_status "Please install direnv and add it to your shell configuration"
    print_status "See: https://direnv.net/docs/installation.html"
fi

# Check if nix is available
if ! command -v nix >/dev/null 2>&1; then
    print_warning "nix is not installed or not in PATH"
    print_status "Please install Nix with flakes enabled"
    print_status "See: https://nixos.org/download.html"
fi

# Success message
echo
print_header "✅ Project setup complete!"
print_status "Next steps:"
echo "  1. cd $PROJECT_PATH"
echo "  2. direnv allow"
echo "  3. Start coding!"
echo
print_status "Happy coding! 🎉" 