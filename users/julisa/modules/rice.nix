{ config, lib, pkgs, ... }: # <--- ASEGÚRATE QUE pkgsUnstable ESTÉ AQUÍ
let

  modifier = "Mod4"; # Mod4 se corresponde con la tecla Super o Win
  modifier1 = "Mod1"; # Mod1 se corresponde con la tecla Alt

  colors = rec {
      # general
      background = "#312f2f";
      background-alt = "#3b4354";
      foreground = "#F1FAEE";
      primary = "#08D9D6";
      secondary = "#047672";
      alert = "#ff2e63";
      disabled = "#707880";

      # rofi <--- ESTA SECCIÓN ES IMPORTANTE
      bg0 = "${colors.background}E6";
      bg1 = "${colors.background-alt}80";
      bg2 = "${colors.primary}E6";
      fg0 = "#DEDEDE";
      fg1 = "${colors.foreground}";
      fg2 = "${colors.disabled}80";
    };


  wallpaperOut = "wallpaper/wallpaper.png";

  brightnessScript = pkgs.writeShellScriptBin "brightness-control" ''
    #!/bin/bash
    # $1 puede ser "up", "down", o un porcentaje como "50%"
    if [[ "$1" == "up" ]]; then
      brightnessctl set +5%
    elif [[ "$1" == "down" ]]; then
      brightnessctl set 5%-
    elif [[ "$1" == *% ]]; then
      brightnessctl set "$1"
    fi
    NEW_PERCENT_VAL=$(brightnessctl -m | cut -d, -f4 | sed 's/%//')
    ${pkgs.libnotify}/bin/notify-send "Brillo" "Nivel: $NEW_PERCENT_VAL%" \
      -h string:x-canonical-private-synchronous:brightness \
      -h int:value:$NEW_PERCENT_VAL -t 1500
  '';


  # Script para activar/desactivar la luz nocturna
  gammastepToggleScript = pkgs.writeShellScriptBin "gammastep-toggle" ''
    #!/bin/sh
    if pgrep -x "gammastep-indicator" > /dev/null
    then
        killall gammastep-indicator
        ${pkgs.libnotify}/bin/notify-send "Luz Nocturna" "Desactivada" -t 1500
    else
        ${pkgs.gammastep}/bin/gammastep-indicator &
        ${pkgs.libnotify}/bin/notify-send "Luz Nocturna" "Activada" -t 1500
    fi
  '';

  # Volume control script with notifications
  volumeScript = pkgs.writeShellScriptBin "volume-control" ''
    #!/bin/bash
    if [[ "$1" != "notify" ]]; then
      case "$1" in
        up) ${pkgs.pamixer}/bin/pamixer -i 5 ;;
        down) ${pkgs.pamixer}/bin/pamixer -d 5 ;;
        mute) ${pkgs.pamixer}/bin/pamixer -t ;;
        set*) PERCENT_VAL=''${1#set}; ${pkgs.pamixer}/bin/pamixer --set-volume $PERCENT_VAL ;;
      esac
    fi
    VOLUME=$(${pkgs.pamixer}/bin/pamixer --get-volume)
    MUTED=$(${pkgs.pamixer}/bin/pamixer --get-mute)
    ICON_VOL=""; if [ $VOLUME -lt 50 ]; then ICON_VOL=""; fi; if [ $VOLUME -eq 0 ]; then ICON_VOL=""; fi
    if [ "$MUTED" = "true" ]; then TEXT="🔇 Silenciado"; else TEXT="$ICON_VOL $VOLUME%"; fi
    ${pkgs.libnotify}/bin/notify-send "Audio" "$TEXT" -h string:x-canonical-private-synchronous:volume -h int:value:$VOLUME -t 1500
  '';

  # --- NUEVOS Scripts para los menús de Rofi (versiones estables) ---
  rofiScriptMusic = pkgs.writeShellScriptBin "rofi-music-stable" ''
    #!/usr/bin/env bash
    CMD_PLAY_PAUSE="⏯️ Play/Pause"; CMD_NEXT="⏭️ Siguiente"; CMD_PREV="⏮️ Anterior"; CMD_STOP="⏹️ Detener"
    chosen=$(echo -e "$CMD_PLAY_PAUSE\n$CMD_NEXT\n$CMD_PREV\n$CMD_STOP" | rofi -dmenu -i -p "Música")
    case "$chosen" in
        "$CMD_PLAY_PAUSE") ${pkgs.playerctl}/bin/playerctl play-pause ;; "$CMD_NEXT") ${pkgs.playerctl}/bin/playerctl next ;;
        "$CMD_PREV") ${pkgs.playerctl}/bin/playerctl previous ;;       "$CMD_STOP") ${pkgs.playerctl}/bin/playerctl stop ;;
    esac
  '';


  rofiScriptBrightness = pkgs.writeShellScriptBin "rofi-brightness-stable" ''
    #!/usr/bin/env bash
    VAL_UP="⬆️ Subir"; VAL_DOWN="⬇️ Bajar"; VAL_25="🔆 25%"; VAL_50="🔆 50%"; VAL_75="🔆 75%"; VAL_100="🔆 100%"
    current_val=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4)
    chosen=$(echo -e "$VAL_UP\n$VAL_DOWN\n$VAL_25\n$VAL_50\n$VAL_75\n$VAL_100" | rofi -dmenu -i -p "Brillo ($current_val)")
    case "$chosen" in
        "$VAL_UP") ${brightnessScript}/bin/brightness-control up ;;   "$VAL_DOWN") ${brightnessScript}/bin/brightness-control down ;;
        "$VAL_25") ${brightnessScript}/bin/brightness-control 25% ;; "$VAL_50") ${brightnessScript}/bin/brightness-control 50% ;;
        "$VAL_75") ${brightnessScript}/bin/brightness-control 75% ;; "$VAL_100") ${brightnessScript}/bin/brightness-control 100% ;;
    esac
  '';

  rofiScriptVolume = pkgs.writeShellScriptBin "rofi-volume-stable" ''
    #!/usr/bin/env bash
    VAL_UP="🔊 Subir"; VAL_DOWN="🔉 Bajar"; VAL_MUTE="🔇 Silenciar/Activar"
    VAL_25="🔈 25%"; VAL_50="🔉 50%"; VAL_75="🔊 75%"; VAL_100="🔊 100%"
    current_val=$(${pkgs.pamixer}/bin/pamixer --get-volume-human)
    chosen=$(echo -e "$VAL_UP\n$VAL_DOWN\n$VAL_MUTE\n$VAL_25\n$VAL_50\n$VAL_75\n$VAL_100" | rofi -dmenu -i -p "Volumen ($current_val)")
    case "$chosen" in
        "$VAL_UP") ${volumeScript}/bin/volume-control up ;;     "$VAL_DOWN") ${volumeScript}/bin/volume-control down ;;
        "$VAL_MUTE") ${volumeScript}/bin/volume-control mute ;; "$VAL_25") ${volumeScript}/bin/volume-control set25 ;;
        "$VAL_50") ${volumeScript}/bin/volume-control set50 ;;   "$VAL_75") ${volumeScript}/bin/volume-control set75 ;;
        "$VAL_100") ${volumeScript}/bin/volume-control set100 ;;
    esac
  '';

  
  # Script para el menú interactivo de Rofi (MODIFICADO)
    controlsMenuScript = pkgs.writeShellScriptBin "rofi-controls-menu" ''
    #!/usr/bin/env bash
    chosen=$(echo -e "☀ Brillo\n Volumen\n Multimedia" | rofi -dmenu -i -p "Control")
    case "$chosen" in
        "☀ Brillo") ${rofiScriptBrightness}/bin/rofi-brightness-stable ;;
        " Volumen") ${rofiScriptVolume}/bin/rofi-volume-stable ;;
        " Multimedia") ${rofiScriptMusic}/bin/rofi-music-stable ;;
    esac
  '';

in
{
  # wallpaper
  xdg.configFile."${wallpaperOut}".source = ../wallpaper/hello.png;

  xsession = {
    enable = true;

    scriptPath = ".hm-xsession";

    # i3-gaps
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config = {
        modifier = "Mod4"; # is Super
        defaultWorkspace = "workspace number 1";
        menu = "${config.programs.rofi.package}/bin/rofi -show drun";
        terminal = "wezterm";
        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 16.0;
        };

        gaps = {
          inner = 10;
          smartBorders = "on";
        };

        bars = [ ];

        floating.criteria = [{ class = "Pavucontrol"; }];

        startup = [
          { command = "systemctl --user restart polybar"; always = true; notification = false; }
          { command = "xset s off -dpms"; always = true; notification = false; }
          { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; always = true; notification = false; }
          # Fixed monitor names: eDP-1 instead of eDP-1-1, HDMI-1 instead of HDMI-0
          # { command = "xrandr --output eDP-1 --auto --left-of HDMI-1"; notification = false; }
          { command = "${pkgs.feh}/bin/feh --bg-scale ${config.xdg.configHome}/${wallpaperOut}"; always = true; notification = false; }
          # System tray applications
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet"; always = true; notification = false; }
          { command = "${pkgs.blueman}/bin/blueman-applet"; always = true; notification = false; }
          { command = "${pkgs.pasystray}/bin/pasystray"; always = true; notification = false; }
          # Auto-mount removable media
          { command = "${pkgs.udiskie}/bin/udiskie -t"; always = true; notification = false; }
          { command = "${pkgs.copyq}/bin/copyq"; always = true; notification = false; }
          { command = "${pkgs.gammastep}/bin/gammastep-indicator"; always = true; notification = false; }
        ];

        keybindings =
          let
            # Fixed resolution for the actual eDP-1 monitor (primary at 0+0)
            main-display-g = "1920x1080+0+0";
            modifier = config.xsession.windowManager.i3.config.modifier;
          in
          lib.mkOptionDefault {

            # Cerrar ventana
            "${modifier}+q" = "kill";

            # Lanzadores de aplicaciones con Rofi
            "${modifier}+d" = "exec ${config.programs.rofi.package}/bin/rofi -show drun"; # <--- COMANDO ROFI CORREGIDO
            "${modifier}+c" = "exec ${controlsMenuScript}/bin/rofi-controls-menu";
            "${modifier}+x" = "exec rofi -show power-menu -modi power-menu:rofi-power-menu";            "${modifier}+z" = "exec rofi -modi emoji -show emoji";
            
            # Lanzadores de aplicaciones comunes
            "${modifier}+b" = "exec firefox";
            "${modifier}+t" = "exec wezterm";
            "${modifier}+n" = "exec ${pkgs.xfce.thunar}/bin/thunar";

            # --- Capturas de Pantalla ---
            # Alt + Espacio: Captura la ventana activa y la COPIA al portapapeles.
            "${modifier1}+space" = ''exec --no-startup-id "maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png"'';
            # Win + P: Inicia el modo de captura INTERACTIVO con flameshot.
            "${modifier}+p" = "exec --no-startup-id flameshot gui";
            # Win + Shift + P: Captura la pantalla COMPLETA y la guarda en un archivo.
            "${modifier}+Shift+p" = ''exec --no-startup-id "mkdir -p $HOME/Imágenes/Capturas && flameshot full -p $HOME/Imágenes/Capturas"'';

            # --- Control del Sistema y Hardware ---
            # Bloquear sesión
            "${modifier}+l" = "exec --no-startup-id i3lock -c 000000";
            # Recargar configuración de i3
            "${modifier}+Shift+r" = "restart";
            # Activar/desactivar luz nocturna (gammastep)
            "${modifier}+g" = "exec --no-startup-id ${gammastepToggleScript}/bin/gammastep-toggle";

            # --- Controles de Hardware (Teclas de Función) ---
            "XF86MonBrightnessUp" = "exec --no-startup-id ${brightnessScript}/bin/brightness-control up";
            "XF86MonBrightnessDown" = "exec --no-startup-id ${brightnessScript}/bin/brightness-control down";
            "XF86AudioRaiseVolume" = "exec --no-startup-id ${volumeScript}/bin/volume-control up";
            "XF86AudioLowerVolume" = "exec --no-startup-id ${volumeScript}/bin/volume-control down";
            "XF86AudioMute" = "exec --no-startup-id ${volumeScript}/bin/volume-control mute";
            
            # --- Manejo de Ventanas (Tiling) ---
            # Cambiar enfoque con flechas
            "${modifier}+Left" = "focus left";
            "${modifier}+Right" = "focus right";
            "${modifier}+Up" = "focus up";
            "${modifier}+Down" = "focus down";
            # Mover ventana activa con flechas
            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Right" = "move right";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+Down" = "move down";

            # Historial del portapapeles
            "${modifier}+v" = "exec copyq toggle";
          };

        colors = {
          focused = {
            background = colors.background-alt;
            border = colors.primary;
            childBorder = colors.primary;
            indicator = colors.alert;
            text = colors.primary;
          };

          focusedInactive = {
            background = colors.background-alt;
            border = colors.background-alt;
            childBorder = colors.secondary;
            indicator = colors.alert;
            text = colors.foreground;
          };

          unfocused = {
            background = colors.background;
            border = colors.background;
            childBorder = colors.background;
            indicator = colors.alert;
            text = colors.foreground;
          };
        };

        window.border = 1;

        workspaceOutputAssign = [{ output = "eDP-1"; workspace = "10"; }];
      };

      # extraConfig = ''for_window [all] title_window_icon padding 10px'';
    };
  };

  # picom (necessary for transparent window)
  services.picom = {
    enable = true;
    fade = true;
    shadow = true;
  };

  # Dunst (Notificaciones) con tu tema personal completo
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
      size = "32x32";
    };
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        geometry = "350x5-30+50";
        indicate_hidden = "yes";
        shrink = "no";
        transparency = 20;
        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 2;
        frame_color = "#${colors.primary}"; # Usamos el color primario
        separator_color = "frame";
        sort = "yes";
        idle_threshold = 120;
        font = "JetBrainsMono Nerd Font 11";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = "yes";
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";
        icon_position = "left";
        max_icon_size = 32;
        sticky_history = "yes";
        history_length = 20;
        browser = "firefox";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        startup_notification = false;
        verbosity = "mesg";
        corner_radius = 8;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action";
        mouse_right_click = "close_all";
      };
      urgency_low = {
        background = "#${colors.background}";
        foreground = "#${colors.foreground}";
        timeout = 10;
      };
      urgency_normal = {
        background = "#${colors.background}";
        foreground = "#${colors.foreground}";
        timeout = 10;
      };
      urgency_critical = {
        background = "#${colors.alert}";
        foreground = "#${colors.foreground}";
        frame_color = "#${colors.alert}";
        timeout = 0;
      };
    };
  };

  # rofi
  programs.rofi = {
    enable = true;
    package = with pkgs; rofi.override { plugins = [ rofi-calc rofi-emoji rofi-systemd ]; };
    extraConfig = {
      show-icons = true;
      modi = "drun,emoji,calc,systemd";
    };

    theme =
      let
        mkL = config.lib.formats.rasi.mkLiteral;
      in
      {
        "*" = {
          bg0 = mkL colors.bg0;
          bg1 = mkL colors.bg1;
          bg2 = mkL colors.bg2;
          fg0 = mkL colors.fg0;
          fg1 = mkL colors.fg1;
          fg2 = mkL colors.fg2;

          background-color = mkL "transparent";
          text-color = mkL "@fg0";

          margin = 0;
          padding = 0;
          spacing = 0;
        };

        window = {
          background-color = mkL "@bg0";
          location = mkL "center";
          width = 640;
          border-radius = 8;
        };

        inputbar = {
          padding = mkL "12px";
          spacing = mkL "12px";
          children = map mkL [ "icon-search" "entry" ];
        };

        icon-search = {
          expand = false;
          filename = "search";
          size = mkL "28px";
          vertical-align = mkL "0.5";
        };

        entry = {
          placeholder = "Search";
          placeholder-color = mkL "@fg2";
          vertical-align = mkL "0.5";
        };

        message = {
          border = mkL "2px 0 0";
          border-color = mkL "@bg1";
          background-color = mkL "@bg1";
        };

        textbox = {
          padding = mkL "8px 24px";
        };

        listview = {
          lines = 10;
          columns = 1;
          fixed-height = false;
          border = mkL "1px 0 0";
          border-color = mkL "@bg1";
        };

        element = {
          padding = mkL "8px 16px";
          spacing = mkL "16px";
          background-color = mkL "transparent";
        };

        element-icon = {
          size = mkL "1em";
          vertical-align = mkL "0.5";
        };

        element-text = {
          text-color = mkL "inherit";
          vertical-align = mkL "0.5";
        };

        "element normal active" = {
          text-color = mkL "@bg2";
        };

        "element selected normal" = {
          background-color = mkL "@bg2";
          text-color = mkL "@fg1";
        };

        "element selected active" = {
          background-color = mkL "@bg2";
          text-color = mkL "@fg1";
        };
      };
  };

  # polybar
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override { pulseSupport = true; iwSupport = true; };
    script = "polybar --reload main &";
    config = {
      "bar/main" = {
        monitor = "eDP-1";
        width = "100%";
        height = 30; # Un poco más delgada
        radius = 6;  # Bordes redondeados
        background = "#${colors.background}AA"; # Fondo con algo de transparencia (AA)
        foreground = "#${colors.foreground}";
        padding-left = 1; # Padding general a la izquierda
        padding-right = 1; # Padding general a la derecha
        module-margin = 2; # Margen entre módulos
        font-0 = "JetBrainsMono Nerd Font:style=Regular:size=10;2";
        # Módulos MODIFICADOS
        modules-left = "i3";
        modules-center = "date"; # Centramos la fecha
        modules-right = "pulseaudio wlan battery tray"; # Quitamos filesystem, memory, cpu
        tray-position = "right";
        enable-ipc = true;
      };
      "module/i3" = { type = "internal/i3"; pin-workspaces = true; label-focused-foreground = "#${colors.primary}"; label-unfocused-foreground = "#${colors.disabled}"; label-urgent-foreground = "#${colors.alert}"; };
      "module/date" = { type = "internal/date"; interval = 1; date = "%I:%M %p"; label = " %date%"; }; # Hora 12h
      "module/pulseaudio" = { type = "internal/pulseaudio"; format-volume = "<ramp-volume> <label-volume>"; label-muted = " Muted"; ramp-volume-0 = ""; ramp-volume-1 = ""; };
      "module/wlan" = { type = "internal/network"; interface-type = "wireless"; interval = 5; format-connected = " %essid%"; format-disconnected = " --"; };
      "module/battery" = {
        type = "internal/battery"; battery = "BAT0"; adapter = "ADP1"; full-at = 99;
        format-charging = "<animation-charging> <label-charging>";
        format-discharging = "<ramp-capacity> <label-discharging>";
        label-charging = "%percentage%%"; label-discharging = "%percentage%%";
        ramp-capacity-0 = "󰁺"; ramp-capacity-1 = "󰁻"; ramp-capacity-2 = "󰁼"; ramp-capacity-3 = "󰁽"; ramp-capacity-4 = "󰁾";
        ramp-capacity-0-foreground = "#${colors.alert}";
        animation-charging-0 = "󰢜"; animation-charging-1 = "󰢝"; animation-charging-framerate = 750;
      };
      "settings" = { screenchange-reload = true; }; # pseudo-transparency lo maneja picom
    };
  };


  # Additional packages for the rice setup  
  home.packages = with pkgs; [
    # Scripts personalizados (SIN pkgs. delante)
    brightnessScript
    volumeScript
    controlsMenuScript # Script principal del menú
    rofiScriptMusic    # Nuevo script para música en Rofi
    rofiScriptBrightness # Nuevo script para brillo en Rofi
    rofiScriptVolume   # Nuevo script para volumen en Rofi
    gammastepToggleScript
    
    # Utilidades del sistema y control
    bc
    libnotify
    pamixer
    i3lock
    networkmanagerapplet
    blueman
    pasystray
    udiskie
    arandr
    pavucontrol
    brightnessctl
    
    # Apariencia y Temas
    lxappearance
    arc-theme
    papirus-icon-theme
    dracula-theme
    gnome.gnome-themes-extra

    
    # Capturas de pantalla
    flameshot
    maim
    xdotool
    xclip
    
    # Fuentes
    font-awesome
    material-design-icons
    
    # Aplicaciones Principales
    xfce.thunar
    copyq
    gammastep
    
    pkgs.playerctl               # Este está bien en pkgs
  
    firefox
  ];
}
