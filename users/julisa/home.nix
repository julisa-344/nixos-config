# ~/nixos-config/users/julisa/home.nix
{ config, pkgs, lib, pkgsUnstable, blesh, ... }:
{
  home.username = "julisa";
  home.homeDirectory = "/home/julisa";
  home.stateVersion = "23.11";
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    # Importa desde la nueva y limpia ubicación
    ./modules/default.nix
    ./modules/app.nix
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-marketplace; [
      github.copilot
      github.copilot-chat
    ];
  };
}