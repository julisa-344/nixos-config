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
    package = pkgsUnstable.vscode;
    extensions = with pkgsUnstable.vscode-extensions; [
      github.copilot
      github.copilot-chat
    ];
  };
  # services.mako.enable = false; # Esta línea ya la quitaste, ¡perfecto!
}