{
  description = "Minimal development environment template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # === Core Tools ===
            git                 # Version control
            curl                # HTTP client
            jq                  # JSON processor
            
            # === Text Editing ===
            neovim              # Text editor (or use 'vim' for minimal vim)
            
            # === Terminal Utilities ===
            tree                # Directory structure
            htop                # Process monitor
            
            # Add your custom packages here:
            # nodejs_20         # For Node.js development
            # python311         # For Python development
            # rustc             # For Rust development
            # go                # For Go development
            # docker            # For containerization
            # postgresql        # For database work
          ];

          shellHook = ''
            echo "🚀 Development Environment Activated!"
            echo ""
            echo "💡 Customize this environment by editing flake.nix"
            echo "📚 Available packages: https://search.nixos.org/packages"
            echo ""
            
            # Set up basic environment
            export EDITOR="nvim"
            
            # Add your custom shell setup here:
            # alias ll='ls -la'
            # export MY_VAR="value"
            # function my-command() { echo "Hello from custom command!"; }
          '';

          # Add environment variables here:
          # NODE_ENV = "development";
          # PYTHONPATH = "./src";
        };
      });
} 