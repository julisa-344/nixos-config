{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Define Python packages for development
        pythonPackages = ps: with ps; [
          # Core packages
          pip
          setuptools
          wheel
          virtualenv
          
          # Development tools
          pytest
          pytest-cov
          black
          isort
          flake8
          mypy
          pylint
          bandit
          
          # Documentation
          sphinx
          mkdocs
          
          # Jupyter and data science
          jupyter
          ipython
          numpy
          pandas
          matplotlib
          seaborn
          scikit-learn
          
          # Web frameworks
          flask
          fastapi
          django
          requests
          httpx
          
          # Database
          psycopg2
          sqlalchemy
          
          # Utility packages
          python-dotenv
          pyyaml
          click
          typer
          rich
          tqdm
        ];

        # Create Python environment
        pythonEnv = pkgs.python311.withPackages pythonPackages;

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # === Python Environment ===
            pythonEnv
            poetry              # Python dependency management
            pdm                 # Alternative Python dependency manager
            
            # === Development Tools ===
            git                 # Version control
            neovim              # Text editor
            alacritty           # Terminal emulator
            
            # === Database Tools ===
            postgresql          # PostgreSQL client
            sqlite              # SQLite
            
            # === Utilities ===
            jq                  # JSON processor
            curl                # HTTP client
            tree                # Directory structure
            fd                  # Better find
            ripgrep             # Better grep
            bat                 # Better cat
            
            # === Build tools (for Python packages with C extensions) ===
            gcc                 # C compiler
            pkg-config          # Package config
            
            # === System monitoring ===
            htop                # Process monitor
          ];

          shellHook = ''
            echo "🐍 Python Development Environment Activated!"
            echo ""
            echo "📦 Available tools:"
            echo "  🐍 Python $(python --version | cut -d' ' -f2)"
            echo "  📦 Poetry $(poetry --version | cut -d' ' -f3)"
            echo "  🧪 pytest $(pytest --version | cut -d' ' -f2)"
            echo ""
            echo "🛠️  Quick start commands:"
            echo "  • python -m venv venv && source venv/bin/activate  # Create virtual environment"
            echo "  • poetry init                                      # Initialize Poetry project"
            echo "  • pytest                                          # Run tests"
            echo "  • black .                                         # Format code"
            echo ""
            echo "💡 Type 'py-help' for more commands"
            echo ""
            
            # Create useful aliases
            alias ll='ls -la'
            alias cat='bat'
            alias grep='rg'
            alias find='fd'
            
            # Python development helper function
            function py-help() {
              echo "🐍 Python Development Helper Commands:"
              echo ""
              echo "📁 Project Setup:"
              echo "  poetry init                  # Initialize Poetry project"
              echo "  poetry add <package>         # Add dependency"
              echo "  poetry add --group dev <pkg> # Add dev dependency"
              echo "  poetry install               # Install dependencies"
              echo "  poetry shell                 # Activate virtual environment"
              echo ""
              echo "🧪 Testing & Quality:"
              echo "  pytest                       # Run tests"
              echo "  pytest --cov                # Run tests with coverage"
              echo "  black .                      # Format code"
              echo "  isort .                      # Sort imports"
              echo "  flake8 .                     # Lint code"
              echo "  mypy .                       # Type checking"
              echo "  bandit -r .                  # Security analysis"
              echo ""
              echo "📊 Data Science:"
              echo "  jupyter notebook             # Start Jupyter notebook"
              echo "  jupyter lab                  # Start Jupyter lab"
              echo "  ipython                      # Interactive Python shell"
              echo ""
              echo "📚 Documentation:"
              echo "  sphinx-quickstart            # Initialize Sphinx docs"
              echo "  mkdocs new <project>         # Initialize MkDocs"
              echo "  mkdocs serve                 # Serve MkDocs locally"
            }
            
            # Set up environment variables
            export EDITOR="nvim"
            export PYTHONPATH="./src:$PYTHONPATH"
            export PIP_DISABLE_PIP_VERSION_CHECK="1"
            
            # Development environment markers
            export DEV_ENV="python-development"
          '';

          # Additional environment variables that persist
          PYTHONPATH = "./src:$PYTHONPATH";
          PIP_DISABLE_PIP_VERSION_CHECK = "1";
          PYTHONDONTWRITEBYTECODE = "1";
        };
      });
} 