{ config, lib, pkgs, ... }: # <--- ASEGÚRATE QUE pkgsUnstable ESTÉ AQUÍ
let

  modifier = "Mod4"; # Mod4 se corresponde con la tecla Super o Win
  modifier1 = "Mod1"; # Mod1 se corresponde con la tecla Alt

  # Catppuccin Mocha Colors - NUEVA PALETA COMPLETA
  colors = rec {
    # Catppuccin Mocha palette
    rosewater = "f5e0dc";
    flamingo = "f2cdcd";
    pink = "f5c2e7";
    mauve = "cba6f7";
    red = "f38ba8";
    maroon = "eba0ac";
    peach = "fab387";
    yellow = "f9e2af";
    green = "a6e3a1";
    teal = "94e2d5";
    sky = "89dceb";
    sapphire = "74c7ec";
    blue = "89b4fa";
    lavender = "b4befe";
    text = "cdd6f4";
    subtext1 = "bac2de";
    subtext0 = "a6adc8";
    overlay2 = "9399b2";
    overlay1 = "7f849c";
    overlay0 = "6c7086";
    surface2 = "585b70";
    surface1 = "45475a";
    surface0 = "313244";
    base = "1e1e2e";
    mantle = "181825";
    crust = "11111b";
    
    # Aliases para compatibilidad con tu configuración actual
    background = base;
    background-alt = surface0;
    foreground = text;
    primary = mauve;
    secondary = lavender;
    alert = red;
    disabled = overlay0;
    
    # Colores específicos para rofi
    bg0 = "${base}E6";
    bg1 = "${surface0}80";
    bg2 = "${mauve}E6";
    fg0 = text;
    fg1 = text;
    fg2 = "${overlay0}80";
  };

  wallpaperOut = "wallpaper/hello.png";

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

  rofiAppMenuScript = pkgs.writeShellScriptBin "rofi-apps-menu" ''
    #!/usr/bin/env bash
    rofi -show drun -display-drun "Applications" \
         -drun-display-format "{name}" \
         -show-icons -icon-theme "Papirus-Dark" \
         -theme-str 'window {width: 60%; height: 70%;}'
  '';

in
{
  # wallpaper - CAMBIAR A CATPPUCCIN
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
          { command = "${pkgs.feh}/bin/feh --bg-scale ${config.xdg.configHome}/${wallpaperOut}"; always = true; notification = false; }
          # System tray applications
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet"; always = true; notification = false; }
          { command = "${pkgs.blueman}/bin/blueman-applet"; always = true; notification = false; }
          { command = "${pkgs.pasystray}/bin/pasystray"; always = true; notification = false; }
          # Auto-mount removable media
          { command = "${pkgs.udiskie}/bin/udiskie -t"; always = true; notification = false; }
          { command = "${pkgs.copyq}/bin/copyq"; always = true; notification = false; }
          { command = "${pkgs.gammastep}/bin/gammastep-indicator"; always = true; notification = false; }
          # NUEVO: Iniciar fcitx5 para cambio de idioma
          { command = "fcitx5 -d"; always = true; notification = false; }
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
            "${modifier}+d" = "exec ${config.programs.rofi.package}/bin/rofi -show drun -show-icons";
            "${modifier}+c" = "exec ${controlsMenuScript}/bin/rofi-controls-menu";
            "${modifier}+x" = "exec rofi -show power-menu -modi power-menu:rofi-power-menu";
            "${modifier}+z" = "exec rofi -modi emoji -show emoji";
            
            # Lanzadores de aplicaciones comunes
            "${modifier}+b" = "exec firefox";
            "${modifier}+t" = "exec wezterm";
            "${modifier}+f" = "exec ${pkgs.xfce.thunar}/bin/thunar";

            # --- CAMBIO DE IDIOMA (NUEVO) ---
            # Ctrl+Space para cambiar idioma (método principal)
            "ctrl+space" = "exec --no-startup-id fcitx5-remote -t";
            # Super+i como alternativa para cambio de idioma
            "${modifier}+i" = "exec --no-startup-id fcitx5-remote -t";

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

            # Control de notificaciones  
            "${modifier}+n" = "exec --no-startup-id dunstctl close";
            "${modifier}+Shift+n" = "exec --no-startup-id dunstctl close-all";
            "${modifier}+ctrl+n" = "exec --no-startup-id dunstctl history-pop";

            # Historial del portapapeles
            "${modifier}+v" = "exec copyq toggle";
          };

        colors = {
          focused = {
            background = "#${colors.surface0}";
            border = "#${colors.mauve}";
            childBorder = "#${colors.mauve}";
            indicator = "#${colors.red}";
            text = "#${colors.text}";
          };

          focusedInactive = {
            background = "#${colors.surface1}";
            border = "#${colors.surface1}";
            childBorder = "#${colors.surface1}";
            indicator = "#${colors.red}";
            text = "#${colors.subtext1}";
          };

          unfocused = {
            background = "#${colors.base}";
            border = "#${colors.base}";
            childBorder = "#${colors.base}";
            indicator = "#${colors.red}";
            text = "#${colors.overlay0}";
          };

          urgent = {
            background = "#${colors.red}";
            border = "#${colors.red}";
            childBorder = "#${colors.red}";
            indicator = "#${colors.red}";
            text = "#${colors.base}";
          };
        };

        window.border = 2; # Borde un poco más grueso para mejor visibilidad

        workspaceOutputAssign = [{ output = "eDP-1"; workspace = "10"; }];
      };

      # extraConfig = ''for_window [all] title_window_icon padding 10px'';
    };
  };

  # picom (efectos visuales mejorados)
  services.picom = {
    enable = true;
    fade = true;
    fadeSteps = [0.03 0.03];
    shadow = true;
    shadowRadius = 12;
    shadowOffsets = [(-7) (-7)];
    shadowOpacity = 0.7;
    
    # Transparencia para ventanas específicas
    opacityRules = [
      "90:class_g = 'Rofi'"
      "95:class_g = 'dunst'"
      "90:class_g = 'Polybar'"
    ];
    
    # Configuración actualizada para la nueva API
    settings = {
      # Backend y optimizaciones
      backend = "glx";
      glx-no-stencil = true;
      glx-copy-from-front = false;
      
      # Mejor rendimiento
      unredir-if-possible = true;
      refresh-rate = 60;
      vsync = true;
      
      # Esquinas redondeadas (nueva sintaxis)
      corner-radius = 8;
      
      # Blur (nueva sintaxis)
      blur = {
        method = "kawase";
        strength = 8;
        deviation = 3.0;
        background = false;
        background-frame = false;
        background-fixed = false;
      };
      
      # Excluir del blur
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];
    };
  };

  # Dunst (Notificaciones) con tu tema personal completo
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
      size = "32x32";
    };
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        geometry = "400x60-20+50";
        indicate_hidden = "yes";
        shrink = "no";
        transparency = 5;
        notification_height = 60;
        separator_height = 3;
        padding = 15;
        horizontal_padding = 15;
        frame_width = 2;
        frame_color = "#${colors.mauve}";
        separator_color = "#${colors.surface0}";
        sort = "yes";
        idle_threshold = 120;
        font = "JetBrainsMono Nerd Font 11";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        word_wrap = "yes";
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";
        icon_position = "left";
        min_icon_size = 24;
        max_icon_size = 32;
        corner_radius = 8;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        background = "#${colors.base}";
        foreground = "#${colors.text}";
        timeout = 5;
      };

      urgency_normal = {
        background = "#${colors.base}";
        foreground = "#${colors.text}";
        timeout = 10;
      };

      urgency_critical = {
        background = "#${colors.red}";
        foreground = "#${colors.base}";
        frame_color = "#${colors.maroon}";
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
        height = 35;
        radius = 8;  # Más redondeado para el look moderno
        background = "#${colors.base}F0"; # Base con transparencia
        foreground = "#${colors.text}";
        padding-left = 2;
        padding-right = 2;
        module-margin = 2;
        font-0 = "JetBrainsMono Nerd Font:style=Regular:size=11;3";
        font-1 = "JetBrainsMono Nerd Font:style=Bold:size=11;3";
        font-2 = "Font Awesome 6 Free:style=Solid:size=11;3";
        font-3 = "Font Awesome 6 Brands:style=Regular:size=11;3";
        
        # Módulos actualizados
        modules-left = "i3";
        modules-center = "date";
        modules-right = "pulseaudio wlan battery tray";
        tray-position = "right";
        tray-padding = 2;
        tray-background = "#${colors.surface0}";
        enable-ipc = true;
        
        # Línea decorativa en la parte superior
        border-top-size = 2;
        border-top-color = "#${colors.mauve}";
      };

      # Módulos actualizados con colores Catppuccin
      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;
        enable-click = true;
        enable-scroll = false;
        format = "<label-state> <label-mode>";
        
        label-focused = " %index% ";
        label-focused-foreground = "#${colors.base}";
        label-focused-background = "#${colors.mauve}";
        label-focused-padding = 1;
        
        label-unfocused = " %index% ";
        label-unfocused-foreground = "#${colors.overlay0}";
        label-unfocused-background = "#${colors.surface0}";
        label-unfocused-padding = 1;
        
        label-visible = " %index% ";
        label-visible-foreground = "#${colors.text}";
        label-visible-background = "#${colors.surface1}";
        label-visible-padding = 1;
        
        label-urgent = " %index% ";
        label-urgent-foreground = "#${colors.base}";
        label-urgent-background = "#${colors.red}";
        label-urgent-padding = 1;
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = " %I:%M %p";
        date-alt = " %A, %B %d";
        label = "%date%";
        label-foreground = "#${colors.text}";
        label-background = "#${colors.surface0}";
        label-padding = 2;
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume = "<ramp-volume> <label-volume>";
        format-volume-foreground = "#${colors.text}";
        format-volume-background = "#${colors.surface0}";
        format-volume-padding = 2;
        
        label-muted = "󰖁 Muted";
        label-muted-foreground = "#${colors.overlay0}";
        label-muted-background = "#${colors.surface0}";
        label-muted-padding = 2;
        
        ramp-volume-0 = "󰕿";
        ramp-volume-1 = "󰖀";
        ramp-volume-2 = "󰕾";
      };

      "module/wlan" = {
        type = "internal/network";
        interface = "wlp0s20f3"; # Ajusta según tu interfaz
        interval = 3;
        format-connected = "<ramp-signal> <label-connected>";
        format-connected-foreground = "#${colors.text}";
        format-connected-background = "#${colors.surface0}";
        format-connected-padding = 2;
        
        label-connected = "%essid%";
        
        format-disconnected = "󰤭 Disconnected";
        format-disconnected-foreground = "#${colors.overlay0}";
        format-disconnected-background = "#${colors.surface0}";
        format-disconnected-padding = 2;
        
        ramp-signal-0 = "󰤯";
        ramp-signal-1 = "󰤟";
        ramp-signal-2 = "󰤢";
        ramp-signal-3 = "󰤥";
        ramp-signal-4 = "󰤨";
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0"; # Ajusta según tu batería
        adapter = "ADP1"; # Ajusta según tu adaptador
        full-at = 98;
        
        format-charging = "<animation-charging> <label-charging>";
        format-charging-foreground = "#${colors.green}";
        format-charging-background = "#${colors.surface0}";
        format-charging-padding = 2;
        
        format-discharging = "<ramp-capacity> <label-discharging>";
        format-discharging-foreground = "#${colors.text}";
        format-discharging-background = "#${colors.surface0}";
        format-discharging-padding = 2;
        
        format-full = "󰁹 <label-full>";
        format-full-foreground = "#${colors.green}";
        format-full-background = "#${colors.surface0}";
        format-full-padding = 2;
        
        label-charging = "%percentage%%";
        label-discharging = "%percentage%%";
        label-full = "Full";
        
        ramp-capacity-0 = "󰁺";
        ramp-capacity-1 = "󰁻";
        ramp-capacity-2 = "󰁼";
        ramp-capacity-3 = "󰁽";
        ramp-capacity-4 = "󰁾";
        ramp-capacity-5 = "󰁿";
        ramp-capacity-6 = "󰂀";
        ramp-capacity-7 = "󰂁";
        ramp-capacity-8 = "󰂂";
        ramp-capacity-9 = "󰁹";
        
        animation-charging-0 = "󰢜";
        animation-charging-1 = "󰢝";
        animation-charging-2 = "󰢞";
        animation-charging-3 = "󰢟";
        animation-charging-4 = "󰢠";
        animation-charging-framerate = 750;
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
