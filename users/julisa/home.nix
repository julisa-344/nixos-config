# ~/nixos-config/users/julisa/home.nix
{ config, pkgs, lib, pkgsUnstable, ... }: # <--- pkgsUnstable ya está disponible aquí

{
  # ... tu configuración existente ...
  home.stateVersion = "24.05";
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    ./modules/default.nix
    ./modules/app.nix
  ];

  programs.vscode = {
    enable = true;
    package = pkgsUnstable.vscode; # Usamos la versión de VS Code de pkgsUnstable
    extensions = with pkgsUnstable.vscode-extensions; [ # <--- CAMBIO IMPORTANTE AQUÍ
      # Ahora las extensiones también vienen de pkgsUnstable
      github.copilot
      github.copilot-chat
      # Si tenías otras extensiones, asegúrate de que estén disponibles en pkgsUnstable.vscode-extensions
    ];
  };

  # services.mako.enable = false; # Esta línea ya la quitaste, ¡perfecto!
}