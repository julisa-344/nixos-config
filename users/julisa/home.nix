# ~/nixos-config/users/julisa/home.nix
{ config, pkgs, lib, pkgsUnstable, blesh, ... }: # Arguments provided by Home Manager and extraSpecialArgs

{
  home.username = "julisa";
  home.homeDirectory = "/home/julisa";

  # IMPORTANT: This should match your NixOS/Home Manager version (e.g., "24.05")
  # The dotfiles flake used 24.05, so we'll assume that for now.
  home.stateVersion = "23.11";

  # Allow unfree packages, as the original dotfiles' home.nix had this.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    ./modules/default.nix
    ./modules/app.nix
  ];

  # Note: pkgsUnstable and blesh are available here via extraSpecialArgs
  # from your main NixOS configuration.
  # The modules within ./modules can use them.
}
