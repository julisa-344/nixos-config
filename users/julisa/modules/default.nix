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
    ../dotfiles/home/modules/bash
    ../dotfiles/home/modules/blesh
    ../dotfiles/home/modules/rice.nix
    ../dotfiles/home/modules/wezterm.nix
    ../dotfiles/home/modules/node
    ../dotfiles/home/modules/rust.nix
    ../dotfiles/home/modules/haskell.nix
    ../dotfiles/home/modules/font.nix
    ../dotfiles/home/modules/i18n
  ];

  # Our own git configuration (replacing the dotfiles one)
  programs.git = {
    enable = true;
    userName = "julisa";  # Set this to Julisa's preferred git username
    userEmail = "julisa@example.com";  # Set this to Julisa's email
    
    extraConfig = {
      init.defaultBranch = "main";
      branch.sort = "-committerdate";
      core.editor = "vim";  # or "nvim" if neovim is preferred
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