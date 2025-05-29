{ config, pkgs, lib, ... }:

let
  pkgsUnstable = config._module.args.pkgsUnstable;
in

{
  home.packages = with pkgs; [
    discord
    element-desktop
    firefox
    pkgsUnstable.google-chrome
    xfce.thunar
    gimp
    lxappearance
    vscode
    screenkey
    vlc
  ];

  # systemd.user.services.my-service = {
  #   Unit = {
  #     Description = "Mi servicio personalizado";
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'echo Hello from app.nix'";
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  # };

  xdg.configFile."discord/settings.json".text = ''
    {
      "IS_MAXIMIZED": false,
      "IS_MINIMIZED": false,
      "WINDOW_BOUNDS": {
        "x": 2024,
        "y": 52,
        "width": 1995,
        "height": 1071
      },
      "BACKGROUND_COLOR": "#202225",
      "SKIP_HOST_UPDATE": true
    }
  '';

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = "firefox.desktop";
      "text/xml" = "firefox.desktop";
      "application/xhtml_xml" = "firefox.desktop";
      "image/webp" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/ftp" = "firefox.desktop";
    };
  };
}
