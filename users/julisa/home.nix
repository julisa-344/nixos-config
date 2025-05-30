# ~/nixos-config/users/julisa/home.nix
{ config, pkgs, lib, pkgsUnstable, blesh, ... }: # These arguments are made available by Home Manager

{
  home.username = "julisa";
  home.homeDirectory = "/home/julisa";

  # IMPORTANT: This should match your NixOS/Home Manager version (e.g., "24.05")
  # The dotfiles flake used 24.05, so we'll assume that for now.
  home.stateVersion = "23.11";

  # Allow unfree packages, as the original dotfiles' home.nix had this.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    ./dotfiles/home/modules/default.nix
    # Import development modules when available
    ./dotfiles/home/modules/app.nix
  ];

  # Note: pkgsUnstable and blesh are available here if they are passed as
  # extraSpecialArgs from your main NixOS configuration (flake.nix).
  # The modules within ./modules might use them.
}
