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

  wallpaperOut = "wallpaper/hello.jpg";

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


  # Script para activar/desactivar la luz nocturna (MEJORADO)
  gammastepToggleScript = pkgs.writeShellScriptBin "gammastep-toggle" ''
    #!/bin/sh
    # Verificar si gammastep o gammastep-indicator están corriendo
    if pgrep -x "gammastep" > /dev/null || pgrep -x "gammastep-indicator" > /dev/null
    then
        # Matar todos los procesos de gammastep
        killall gammastep gammastep-indicator 2>/dev/null
        ${pkgs.libnotify}/bin/notify-send "Luz Nocturna" "Desactivada 🌕" -t 1500
    else
        # Iniciar gammastep-indicator
        ${pkgs.gammastep}/bin/gammastep-indicator &
        ${pkgs.libnotify}/bin/notify-send "Luz Nocturna" "Activada 🌙" -t 1500
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
    chosen=$(echo -e "$CMD_PLAY_PAUSE\n$CMD_NEXT\n$CMD_PREV\n$CMD_STOP" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Música")
    case "$chosen" in
        "$CMD_PLAY_PAUSE") ${pkgs.playerctl}/bin/playerctl play-pause ;; "$CMD_NEXT") ${pkgs.playerctl}/bin/playerctl next ;;
        "$CMD_PREV") ${pkgs.playerctl}/bin/playerctl previous ;;       "$CMD_STOP") ${pkgs.playerctl}/bin/playerctl stop ;;
    esac
  '';


  rofiScriptBrightness = pkgs.writeShellScriptBin "rofi-brightness-stable" ''
    #!/usr/bin/env bash
    VAL_UP="⬆️ Subir"; VAL_DOWN="⬇️ Bajar"; VAL_25="🔆 25%"; VAL_50="🔆 50%"; VAL_75="🔆 75%"; VAL_100="🔆 100%"
    current_val=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4)
    chosen=$(echo -e "$VAL_UP\n$VAL_DOWN\n$VAL_25\n$VAL_50\n$VAL_75\n$VAL_100" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Brillo ($current_val)")
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
    chosen=$(echo -e "$VAL_UP\n$VAL_DOWN\n$VAL_MUTE\n$VAL_25\n$VAL_50\n$VAL_75\n$VAL_100" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Volumen ($current_val)")
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
    exec ${pkgs.rofi}/bin/rofi -show drun -display-drun "Applications" \
         -drun-display-format "{name}" \
         -show-icons -icon-theme "Papirus-Dark" \
         -theme-str 'window {width: 60%; height: 70%;}'
  '';

in
{
  # wallpaper - CAMBIAR A CATPPUCCIN
  xdg.configFile."${wallpaperOut}".source = ../wallpaper/hello.jpg;

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
        menu = "${rofiAppMenuScript}/bin/rofi-apps-menu";  # CORREGIR
        terminal = "warp-terminal";
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
          # ELIMINADO: pasystray para evitar iconos duplicados (polybar ya maneja el audio)
          # Auto-mount removable media
          { command = "${pkgs.udiskie}/bin/udiskie -t"; always = true; notification = false; }
          { command = "${pkgs.copyq}/bin/copyq"; always = true; notification = false; }
          { command = "${pkgs.gammastep}/bin/gammastep-indicator"; always = true; notification = false; }
          # NUEVO: Iniciar fcitx5 para cambio de idioma
          { command = "fcitx5 -d"; always = true; notification = false; }
        ];

        # Configuración para arrastrar ventanas con el mouse
        floating.modifier = "Mod4";  # Usar Super/Win key para arrastrar ventanas flotantes
        
        keybindings =
          let
            # Fixed resolution for the actual eDP-1 monitor (primary at 0+0)
            main-display-g = "1920x1080+0+0";
            modifier = config.xsession.windowManager.i3.config.modifier;
          in
          lib.mkOptionDefault {

            # Cerrar ventana
            "${modifier}+q" = "kill";

            # Lanzadores de aplicaciones con Rofi (CORREGIDO)
            "${modifier}+d" = "exec ${rofiAppMenuScript}/bin/rofi-apps-menu";  # Usar nuestro script
            "${modifier}+c" = "exec ${controlsMenuScript}/bin/rofi-controls-menu";
            "${modifier}+x" = "exec rofi -show power-menu -modi power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu";   # Usar el módulo dedicado
            "${modifier}+z" = "exec rofi -modi emoji -show emoji -theme-str 'window {width: 30%; height: 50%;}'";

            # Lanzadores de aplicaciones comunes (CORREGIDO)
            "${modifier}+b" = "exec firefox";
            "${modifier}+t" = "exec warp-terminal";
            "${modifier}+n" = "exec ${pkgs.xfce.thunar}/bin/thunar";  # Mover thunar a Super+n
            "${modifier}+f" = "fullscreen toggle";  # Super+f para pantalla completa

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

            # --- Controles de Ventanas Flotantes ---
            # Hacer que la ventana actual sea flotante/tiling
            "${modifier}+Shift+space" = "floating toggle";
            # Cambiar enfoque entre ventanas flotantes y tiling
            "${modifier}+space" = "focus mode_toggle";
            # Centrar ventana flotante
            "${modifier}+Shift+c" = "move position center";
            
            # --- Modos de Redimensionar y Mover ---
            "${modifier}+r" = "mode resize";
            "${modifier}+m" = "mode move";

            # Control de notificaciones
            "${modifier}+e" = "exec --no-startup-id dunstctl close";
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
        
        # Modos para redimensionar y mover ventanas
        modes = {
          resize = {
            "Left" = "resize shrink width 10 px or 10 ppt";
            "Down" = "resize grow height 10 px or 10 ppt";
            "Up" = "resize shrink height 10 px or 10 ppt";
            "Right" = "resize grow width 10 px or 10 ppt";
            "h" = "resize shrink width 10 px or 10 ppt";
            "j" = "resize grow height 10 px or 10 ppt";
            "k" = "resize shrink height 10 px or 10 ppt";
            "l" = "resize grow width 10 px or 10 ppt";
            "Return" = "mode default";
            "Escape" = "mode default";
          };
          
          move = {
            "Left" = "move left 20px";
            "Down" = "move down 20px";
            "Up" = "move up 20px";
            "Right" = "move right 20px";
            "h" = "move left 20px";
            "j" = "move down 20px";
            "k" = "move up 20px";
            "l" = "move right 20px";
            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };
      };

      # Configuración adicional para mejorar el arrastre de ventanas
      extraConfig = ''
        # Permitir arrastrar ventanas flotantes manteniendo presionado Mod4 (Super/Win) + botón izquierdo del mouse
        # Para redimensionar ventanas flotantes: Mod4 + botón derecho del mouse
        floating_modifier Mod4
        
        # Hacer que ciertas ventanas sean flotantes por defecto
        for_window [class="Pavucontrol"] floating enable
        for_window [class="Arandr"] floating enable
        for_window [class="Lxappearance"] floating enable
        for_window [class="Nm-connection-editor"] floating enable
        for_window [class="Copyq"] floating enable
        for_window [window_role="pop-up"] floating enable
        for_window [window_role="task_dialog"] floating enable
        
        # Configurar bordes para ventanas flotantes
        for_window [floating] border pixel 2
      '';
    };
  };

  # picom (comentado temporalmente debido a problemas de compatibilidad)
  # services.picom = {
  #   enable = true;
  #   fade = true;
  #   fadeSteps = [0.03 0.03];
  #   shadow = true;
  #   shadowRadius = 12;
  #   shadowOffsets = [(-7) (-7)];
  #   shadowOpacity = 0.7;
    
  #   # Transparencia para ventanas específicas
  #   opacityRules = [
  #     "90:class_g = 'Rofi'"
  #     "95:class_g = 'dunst'"
  #     "90:class_g = 'Polybar'"
  #   ];
    
  #   # Configuración básica
  #   settings = {
  #     backend = "glx";
  #     vsync = true;
  #     corner-radius = 8;
      
  #     # Blur básico (si es compatible)
  #     blur-method = "kawase";
  #     blur-strength = 5;
  #   };
  # };

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
    plugins = with pkgs; [ rofi-calc rofi-emoji ];  # CORREGIR: mover plugins aquí
    extraConfig = {
      show-icons = true;
      modi = "drun,emoji,calc";  # CORREGIR: quitar systemd si no está disponible
      icon-theme = "Papirus-Dark";
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
        radius = 8;
        background = "#${colors.base}F0";
        foreground = "#${colors.text}";
        padding-left = 2;
        padding-right = 2;
        module-margin = 2;
        font-0 = "JetBrainsMono Nerd Font:style=Regular:size=11;3";
        font-1 = "JetBrainsMono Nerd Font:style=Bold:size=11;3";
        font-2 = "Font Awesome 6 Free:style=Solid:size=11;3";
        font-3 = "Font Awesome 6 Brands:style=Regular:size=11;3";
        
        # Módulos reorganizados como en tu imagen
        modules-left = "i3 xkeyboard xrandr";  # Workspaces + teclado + pantallas
        modules-center = "date";        # Hora en el centro
        modules-right = "filesystem pulseaudio wlan battery gammastep tray";
        tray-position = "right";
        tray-padding = 2;
        tray-background = "#${colors.surface0}";
        enable-ipc = true;
        
        border-top-size = 2;
        border-top-color = "#${colors.mauve}";
        
        # Hacer clickeable los módulos
        click-left = "";
        click-middle = "";
        click-right = "";
      };

      # Módulo i3 mejorado
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

      # Nuevo módulo de teclado/idioma
      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        blacklist-0 = "num lock";
        blacklist-1 = "caps lock";
        format = "<label-layout>";
        format-foreground = "#${colors.text}";
        format-background = "#${colors.surface0}";
        format-padding = 2;
        label-layout = "󰌌 %layout%";
        click-left = "fcitx5-remote -t";
      };

      # Módulo de fecha/hora clickeable
      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = " %I:%M %p";
        date-alt = " %A, %B %d";
        label = "%date%";
        label-foreground = "#${colors.text}";
        label-background = "#${colors.surface0}";
        label-padding = 2;
        # Click para mostrar calendario
        click-left = "gnome-calendar";
        click-right = "gsimplecal";
      };

      # Módulo de sistema de archivos
      "module/filesystem" = {
        type = "internal/fs";
        interval = 25;
        mount-0 = "/";
        format-mounted = "<ramp-capacity> <label-mounted>";
        format-mounted-foreground = "#${colors.text}";
        format-mounted-background = "#${colors.surface0}";
        format-mounted-padding = 2;
        label-mounted = "%percentage_used%%";
        ramp-capacity-0 = "󰋊";
        ramp-capacity-1 = "󰋋";
        ramp-capacity-2 = "󰋌";
        click-left = "thunar";
      };

      # Audio mejorado y clickeable
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
        
        # Hacer clickeable
        click-left = "pavucontrol";
        click-right = "${volumeScript}/bin/volume-control mute";
        scroll-up = "${volumeScript}/bin/volume-control up";
        scroll-down = "${volumeScript}/bin/volume-control down";
      };

      # WiFi clickeable
      "module/wlan" = {
        type = "internal/network";
        interface = "wlp0s20f3";
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
        
        # Hacer clickeable
        click-left = "nm-connection-editor";
        click-right = "nmcli radio wifi off && sleep 2 && nmcli radio wifi on";
      };

      # Batería clickeable
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "ADP1";
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
        
        # Hacer clickeable
        click-left = "gnome-power-statistics";
      };

      # Módulo para luz nocturna (ARREGLADO)
      "module/gammastep" = {
        type = "custom/script";
        exec = "if pgrep -x gammastep > /dev/null || pgrep -x gammastep-indicator > /dev/null; then echo '󰌵 Night'; else echo '󰌶 Day'; fi";
        interval = 5;
        format-foreground = "#${colors.yellow}";
        format-background = "#${colors.surface0}";
        format-padding = 2;
        click-left = "${gammastepToggleScript}/bin/gammastep-toggle";
        click-right = "killall gammastep gammastep-indicator 2>/dev/null || ${pkgs.gammastep}/bin/gammastep-indicator &";
      };

      # Nuevo módulo para mostrar pantallas múltiples
      "module/xrandr" = {
        type = "custom/script";
        exec = "xrandr --query | grep ' connected' | wc -l | awk '{print \"󰍹 \" $1}'";
        interval = 10;
        format-foreground = "#${colors.blue}";
        format-background = "#${colors.surface0}";
        format-padding = 2;
        click-left = "arandr";
        click-right = "autorandr --change";
      };

      "settings" = { screenchange-reload = true; };
    };
  };


  # Additional packages for the rice setup  
  home.packages = with pkgs; [
    # Scripts personalizados
    brightnessScript
    volumeScript
    controlsMenuScript
    rofiScriptMusic
    rofiScriptBrightness
    rofiScriptVolume
    gammastepToggleScript
    rofiAppMenuScript      # AGREGAR
    
    # Utilidades del sistema y control
    bc
    libnotify
    pamixer
    i3lock
    networkmanagerapplet
    blueman
    # ELIMINADO: pasystray (causaba iconos duplicados, polybar maneja el audio)
    udiskie
    arandr
    autorandr
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
    playerctl
    firefox
    warp-terminal          # Terminal moderna con IA
    
    # Rofi y extensiones (CORREGIR)
    rofi-calc              # AGREGAR
    rofi-emoji             # AGREGAR
    
    # CORREGIR ESTAS LÍNEAS:
    gnome.gnome-calendar          # CAMBIAR: gnome-calendar → gnome.gnome-calendar
    gnome.gnome-power-manager     # MANTENER como está
  ];
}
