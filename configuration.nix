# ~/nixos-config/configuration.nix - VERSIÓN CORREGIDA Y SIMPLIFICADA
{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  programs.zsh.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "julixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Lima"; # Zona horaria de Perú

  # Configuración de idioma para Perú
  i18n.defaultLocale = "es_PE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_PE.UTF-8";
    LC_IDENTIFICATION = "es_PE.UTF-8";
    LC_MEASUREMENT = "es_PE.UTF-8";
    LC_MONETARY = "es_PE.UTF-8";
    LC_NAME = "es_PE.UTF-8";
    LC_NUMERIC = "es_PE.UTF-8";
    LC_PAPER = "es_PE.UTF-8";
    LC_TELEPHONE = "es_PE.UTF-8";
    LC_TIME = "es_PE.UTF-8";
  };

  # Configuración del servidor X y teclado
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
    
    # Configuración del teclado para España/US
    xkb = {
      layout = "us,es";
      variant = ",";
      options = "grp:ctrl_space_toggle"; # Ctrl+Space para cambiar
    };
  };

  # Sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Tailscale VPN
  services.tailscale.enable = true;
  
  # Abrir puertos de Tailscale en el firewall
  networking.firewall = {
    enable = true;
    # Confiar en la interfaz de Tailscale
    trustedInterfaces = [ "tailscale0" ];
    # Permitir el puerto UDP de Tailscale
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Definición de tu usuario
  users.users.julisa = {
    isNormalUser = true;
    description = "Julisa";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      i3-gaps
      dmenu
      i3status
      i3lock
      htop
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    nix-direnv
    tailscale  # Agregar cliente de Tailscale
    dconf      # AGREGAR DCONF
    glib       # para gsettings
    # Herramientas básicas del sistema
    coreutils  # Incluye grep, ls, cat, etc.
    gnugrep    # grep explícito
    findutils  # find, xargs, etc.
    gawk       # awk
    gnused     # sed
    util-linux # herramientas básicas de Linux
  ];

  system.stateVersion = "23.11";

  # Configuración de gestión de energía
  services.logind = {
    lidSwitch = "ignore";        # No suspender al cerrar la tapa
    powerKey = "ignore";         # No apagar con el botón de encendido
    extraConfig = ''
      HandlePowerKey=ignore
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      IdleAction=ignore
      IdleActionSec=0
    '';
  };

  services = {
    # ... otros servicios ...
    
    # Habilitar dconf para configuraciones GTK
    dbus.enable = true;
    
    # Habilitar GNOME Keyring y servicios relacionados
    gnome = {
      gnome-keyring.enable = true;
    };
  };
}