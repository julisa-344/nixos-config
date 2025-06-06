{ config, lib, pkgs, ... }:

{
  # Instalar Warp terminal
  home.packages = with pkgs; [
    warp-terminal
  ];

  # Configuración de variables de entorno para Warp
  home.sessionVariables = {
    # Configurar Warp como terminal por defecto
    TERMINAL = "warp-terminal";
  };

  # Crear un alias para facilitar el uso
  programs.bash.shellAliases = {
    warp = "warp-terminal";
  };

  programs.zsh.shellAliases = {
    warp = "warp-terminal";
  };

  # Configurar aplicaciones por defecto
  xdg.mimeApps.defaultApplications = {
    "application/x-terminal-emulator" = "warp-terminal.desktop";
  };
}