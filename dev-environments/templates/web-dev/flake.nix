{
  description = "Full-stack web development environment";

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
          requests
          urllib3
          
          # Development tools
          pytest
          black
          flake8
          mypy
          pylint
          
          # Web frameworks
          flask
          fastapi
          django
          
          # Data science basics
          numpy
          pandas
          
          # Other useful packages
          python-dotenv
          pyyaml
          click
        ];

        # Create Python environment
        pythonEnv = pkgs.python311.withPackages pythonPackages;

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # === Core Development Tools ===
            pythonEnv           # Python with development packages
            nodejs_20           # Node.js LTS
            yarn                # Package manager
            pnpm                # Alternative package manager
            
            # === Container Tools ===
            docker              # Docker CLI
            docker-compose      # Docker Compose
            podman              # Alternative to Docker
            buildah             # Container building tool
            
            # === Terminal & Editor Tools ===
            warp-terminal       # Terminal emulator moderno con IA
            wezterm             # Alternative terminal
            neovim              # Text editor
            vscode              # VS Code (if you prefer)
            
            # === Development Utilities ===
            git                 # Version control
            gh                  # GitHub CLI
            jq                  # JSON processor
            yq                  # YAML processor
            curl                # HTTP client
            wget                # Download tool
            htop                # Process monitor
            tree                # Directory structure
            fd                  # Better find
            ripgrep             # Better grep
            bat                 # Better cat
            exa                 # Better ls
            
            # === Database Tools ===
            postgresql          # PostgreSQL client
            redis               # Redis client
            sqlite              # SQLite
            
            # === File Processing ===
            unzip               # Archive extraction
            zip                 # Archive creation
            gzip                # Compression
            
            # === Network Tools ===
            netcat              # Network utility
            nmap                # Network scanner
            
            # === Build Tools ===
            gnumake             # Make
            gcc                 # C compiler
            pkg-config          # Package config
            
            # === Cloud Tools ===
            awscli2             # AWS CLI
            google-cloud-sdk    # Google Cloud SDK
            terraform           # Infrastructure as code
            
            # === Monitoring ===
            htop                # System monitor
            btop                # Better system monitor
            
            # === Documentation ===
            pandoc              # Document converter
            
            # === Development Servers ===
            nginx               # Web server
            caddy               # Modern web server
          ];

          # Environment variables
          shellHook = ''
            echo "🚀 Web Development Environment Activated!"
            echo ""
            echo "📦 Available tools:"
            echo "  🐍 Python $(python --version | cut -d' ' -f2)"
            echo "  📦 Node.js $(node --version)"
            echo "  🐳 Docker $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
            echo "  🔧 docker-compose $(docker-compose --version | cut -d' ' -f4 | cut -d',' -f1)"
            echo ""
            echo "🛠️  Quick start commands:"
            echo "  • python -m venv venv && source venv/bin/activate  # Create Python virtual env"
            echo "  • npm init -y                                      # Initialize Node.js project"
            echo "  • docker-compose up -d                            # Start services"
            echo ""
            echo "💡 Type 'dev-help' for more commands"
            echo ""
            
            # Create useful aliases and functions
            alias ll='exa -la'
            alias cat='bat'
            alias grep='rg'
            alias find='fd'
            alias ps='htop'
            
            # Development helper function
            function dev-help() {
              echo "🔧 Development Helper Commands:"
              echo ""
              echo "📁 Project Setup:"
              echo "  create-react-app <name>     # Create React app"
              echo "  npm create vue@latest <name>  # Create Vue app"
              echo "  django-admin startproject <name>  # Create Django project"
              echo "  flask run                   # Run Flask development server"
              echo ""
              echo "🐳 Docker Commands:"
              echo "  docker-compose up -d        # Start services in background"
              echo "  docker-compose logs -f      # Follow logs"
              echo "  docker-compose down         # Stop services"
              echo ""
              echo "🗄️  Database Commands:"
              echo "  psql postgres://user:pass@localhost/db  # Connect to PostgreSQL"
              echo "  redis-cli                   # Connect to Redis"
              echo "  sqlite3 database.db         # Open SQLite database"
              echo ""
              echo "🔍 Analysis Tools:"
              echo "  htop                        # System monitor"
              echo "  docker stats                # Container resource usage"
              echo "  nmap localhost              # Network scan"
            }
            
            # Set up common environment variables
            export EDITOR="nvim"
            export BROWSER="firefox"
            export TERM="xterm-256color"
            
            # Docker environment (if rootless is configured)
            export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
            
            # Development environment markers
            export DEV_ENV="web-development"
            export NODE_ENV="development"
            export FLASK_ENV="development"
            export DJANGO_SETTINGS_MODULE="development"
          '';

          # Additional environment variables that persist
          NODE_ENV = "development";
          PYTHONPATH = "./src:$PYTHONPATH";
          PIP_DISABLE_PIP_VERSION_CHECK = "1";
        };
      });
} 