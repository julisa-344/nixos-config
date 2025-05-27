# ~/nixos-config/configuration.nix
{ config, pkgs, lib, ... }: # Added lib for later use if needed

let
  homeManagerPath = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz"; # Asegúrate de que coincida con tu canal
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"; # Reemplaza con el SHA256 correcto
  };
  homeManagerNixOSModule = import (homeManagerPath + "/nixos");
in

{
  imports =
    [ 
      ./hardware-configuration.nix 
      <home-manager/nixos> # home-manager, duh
    ];
  programs.zsh.enable = true;

  # Bootloader (ensure this matches your hardware/preference)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.enable = true; # Example for GRUB
  # boot.loader.grub.device = "/dev/sdX"; # Or "nodev" for EFI

  programs.home-manager.enable = true;

  home-manager.users.julisa =
    let
      pkgsUnstable = import <nixpkgs-unstable> { system = config.system.platform; };
    in
    import ./users/julisa/home.nix {
      config = config;
      pkgs = pkgs;
      lib = lib;
      pkgsUnstable = pkgsUnstable;
      blesh = null; # Si no estás usando 'blesh', puedes dejarlo como null o removerlo de home.nix
    };

  networking.hostName = "julixos"; # Define your desired hostname
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/New_York"; # e.g., "Europe/Berlin"

  # Select internationalisation properties
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
  # sound.enable = true;
  hardware.pulseaudio.enable = false; # Disable pulseaudio if using pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true; # If you need JACK support
  };
  
  # Define your user account(s)
  users.users.julisa = { # Replace 'julisa' with your actual username
    isNormalUser = true;
    description = "Julisa";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ]; # Add groups as needed
    shell = pkgs.zsh; # Example: set default shell
    packages = with pkgs; [
      xterm
      alacritty
      firefox
      i3-gaps # For i3 window manager
      dmenu   # Application launcher for i3
      i3status # Status bar for i3
      i3lock  # Screen locker for i3
      htop
      zsh
      # Add other essential system-wide packages for the user here
    ];
  };

  # Enable X server and i3 window manager
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true; # Or another display manager like GDM, SDDM
    windowManager.i3.enable = true;
    # layout = "us"; # Optional: set keyboard layout
    # xkbOptions = "eurosign:e,caps:escape"; # Optional: XKB options
  };

  # Allow unfree packages if needed
  nixpkgs.config.allowUnfree = true;

  # Add any custom system packages
  environment.systemPackages = with pkgs; [
    git
    vim # Or your preferred editor
    wget
    curl
    # Add other system-wide command-line tools
  ];

  # Firewall (optional, but recommended)
  # networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ 22 /* SSH */ ];

  system.stateVersion = "23.11"; # IMPORTANT: Set to your current NixOS version
}
