{ config, pkgs, lib, pkgsUnstable, ... }:

{
  imports = [
    ./modules
  ];

  # Información básica del usuario
  home = {
    username = "julisa";
    homeDirectory = "/home/julisa";
    stateVersion = "24.05"; # Usar la versión correcta de home.nix
  };

  # Configuración de nixpkgs
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  # Permitir que Home Manager gestione fonts
  fonts.fontconfig.enable = true;

  # Programas básicos
  programs = {
    home-manager.enable = true;
    
    # VSCode con extensiones
    vscode = {
      enable = true;
      package = pkgsUnstable.vscode;
      extensions = with pkgsUnstable.vscode-extensions; [
        github.copilot
        github.copilot-chat
      ];
    };
  };
}