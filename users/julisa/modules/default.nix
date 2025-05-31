{ config, pkgs, lib, ... }:

{
  imports = [
    # Import most dotfiles modules but exclude git.nix due to hardcoded author info
    ../dotfiles/home/modules/app.nix
    ../dotfiles/home/modules/obs.nix
    ../dotfiles/home/modules/cli.nix
    # ../dotfiles/home/modules/git.nix  # EXCLUDED - has hardcoded author info
    ../dotfiles/home/modules/gpg.nix
    ../dotfiles/home/modules/neovim
    ../dotfiles/home/modules/starship
    ../dotfiles/home/modules/neofetch.nix
    ../dotfiles/home/modules/cava.nix
    ../dotfiles/home/modules/cxxmatrix.nix
    ../dotfiles/home/modules/rofi-power-menu.nix
    ../dotfiles/home/modules/direnv.nix
    # Using our own zsh config instead of bash
    # ../dotfiles/home/modules/bash
    # ../dotfiles/home/modules/blesh  # EXCLUDED - requires external source, causing build issues
    ../dotfiles/home/modules/rice.nix
    ../dotfiles/home/modules/wezterm.nix
    ../dotfiles/home/modules/node
    ../dotfiles/home/modules/rust.nix
    ../dotfiles/home/modules/haskell.nix
    ../dotfiles/home/modules/font.nix
    # ../dotfiles/home/modules/i18n  # EXCLUDED - causes Asian input method activation
  ];

  # Zsh configuration (replacing bash since user prefers zsh)
  programs.zsh = {
    enable = true;
    
    # History settings
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };
    
    # Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git" 
        "sudo" 
        "docker" 
        "npm" 
        "node" 
        "python" 
        "systemd" 
        "direnv"
      ];
      theme = ""; # We use starship instead
    };

    # Enable auto suggestions and syntax highlighting
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    
    # Shell aliases from the original bash config
    shellAliases = {
      # Basic utilities
      ls = "lsd";
      ll = "ls -alF";
      la = "ls -A";
      
      # Git shortcuts (basic ones)
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      
      # System shortcuts
      raw = "command";  # Run command without alias
      copy = "xsel -bi";
      
      # Rofi shortcuts
      "r:calc" = "rofi -show calc -modi calc -no-show-match -no-sort";
      "r:emoji" = "rofi -modi emoji -show emoji";
      
      # Audio visualizer
      "show:audio-visualizer" = "cava";
      "show:clock" = "tty-clock -c -C 4";
      
      # WiFi controls
      "wifi:on" = "nmcli radio wifi on";
      "wifi:off" = "nmcli radio wifi off";
      
      # Power
      cya = "systemctl poweroff";
    };
    
    # Additional configuration
    initExtra = ''
      # Environment variables
      export EDITOR="nvim"
      export BROWSER="firefox"
      export TERMINAL="wezterm"
      
      # Nix environment
      export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels''${NIX_PATH:+:$NIX_PATH}
      
      # Custom functions from the original bash config
      bash:restart() {
        exec zsh -l
      }
      
      cd:conf() {
        cd ~/.config
      }
      
      cd:git-top() {
        cd $(git rev-parse --show-toplevel 2>/dev/null || echo ".")
      }
      
      template:ls() {
        nix flake show 'github:tars0x9752/templates'
      }
      
      template:use() {
        if [[ -z "$1" ]]; then
          echo "a template name required."
        elif [[ -z "$2" ]]; then
          echo "a dir name required."
        else
          nix flake new "$2" -t "github:tars0x9752/templates#$1"          
        fi
      }
      
      # Screenshot functions
      img:screenshot() {
        if [[ -z "$1" ]]; then
          echo "a geometry required."
        elif [[ -z "$2" ]]; then
          echo "a file name required."
        else
          echo "Take a screenshot after 3 seconds."
          sleep 3
          maim -g $1 $2
        fi
      }
      
      img:screenshot-display1() {
        img:screenshot 1920x1080+1920+0 $1
      }
      
      img:screenshot-display2() {
        img:screenshot 1920x1080+0+0 $1
      }
      
      # QR code functions
      qr:decode() {
        maim -qs | zbarimg -q --raw - | xclip -selection clipboard -f
      }
      
      qr:encode() {
        qrencode -t ANSI $1
      }
      
      qr:encode-png() {
        qrencode -o $1 $2
      }
      
      show:screenkey.start() {
        screenkey &
      }
      
      show:screenkey.end() {
        pkill screenkey
      }
      
      # Enable completion for custom commands
      autoload -U compinit && compinit
      
      # Enable starship prompt
      eval "$(starship init zsh)"
    '';
  };

  # Our own git configuration (replacing the dotfiles one)
  programs.git = {
    enable = true;
    userName = "julisa";  # Set this to Julisa's preferred git username
    userEmail = "julisa@example.com";  # Set this to Julisa's email
    
    extraConfig = {
      init.defaultBranch = "main";
      branch.sort = "-committerdate";
      core.editor = "nvim";  # or "vim" if neovim is preferred
      pull.ff = "only";
    };

    # Enable delta for better diffs (from the original config)
    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers";
        syntax-theme = "base16";
        delta.navigate = true;
      };
    };
  };

  # Global git ignore file
  xdg.configFile."git/ignore".text = ''
    .direnv
    .DS_Store
    *.swp
    *.swo
    .vscode/
    .idea/
  '';
} 