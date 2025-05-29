# ~/nixos-config/users/julisa/home.nix
{ config, pkgs, lib, blesh, ... }: # These arguments are made available by Home Manager

{
  home.username = "julisa";
  home.homeDirectory = "/home/julisa";

  # IMPORTANT: This should match your NixOS/Home Manager version (e.g., "24.05")
  # The dotfiles flake used 24.05, so we'll assume that for now.
  home.stateVersion = "23.11";

  # programs.home-manager.enable = true;

  # Allow unfree packages, as the original dotfiles' home.nix had this.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    ./modules/default.nix

    # Cambiar esto:
    ./modules/app.nix

    # Por esto:
    # (import ./modules/app.nix {
    #   inherit config pkgs lib pkgsUnstable;
    # })
  ];

  # Note: pkgsUnstable and blesh are available here if they are passed as
  # extraSpecialArgs from your main NixOS configuration (flake.nix).
  # The modules within ./modules might use them.
}
