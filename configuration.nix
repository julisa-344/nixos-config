# ~/nixos-config/configuration.nix - VERSIÓN CORREGIDA Y SIMPLIFICADA
{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      # La línea "<home-manager/nixos>" ha sido ELIMINADA. El Flake se encarga de esto.
    ];

  programs.zsh.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # La sección "home-manager = { ... };" ha sido ELIMINADA COMPLETAMENTE.
  # El Flake se encarga de configurar y llamar a home.nix.

  networking.hostName = "julixos"; # ¡Perfecto! Usaremos este nombre.
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
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

  # Definición de tu usuario
  users.users.julisa = {
    isNormalUser = true;
    description = "Julisa";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      alacritty
      firefox
      i3-gaps
      dmenu
      i3status
      i3lock
      htop
    ];
  };

  # Entorno gráfico
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    nix-direnv
  ];

  system.stateVersion = "23.11";
}