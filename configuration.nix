# ~/nixos-config/configuration.nix
{ config, pkgs, lib, ... }: # Added lib for later use if needed

let
  unstableTarball = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  };
  pkgsUnstable = import unstableTarball { config = config.nixpkgs.config; };
in

{
  imports =
    [    
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];
 
  programs.zsh.enable = true;

  # Enable experimental features for flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader (ensure this matches your hardware/preference)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.enable = true; # Example for GRUB
  # boot.loader.grub.device = "/dev/sdX"; # Or "nodev" for EFI

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    
    users.julisa = import ./users/julisa/home.nix;
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
  
  # Enable Docker for development (rootless)
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  
  # Define your user account(s)
  users.users.julisa = { # Replace 'julisa' with your actual username
    isNormalUser = true;
    description = "Julisa";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ]; # Added docker group
    shell = pkgs.zsh; # Example: set default shell
    packages = with pkgs; [
      # Core terminal apps
      alacritty
      firefox
      
      # i3 window manager packages
      i3-gaps # For i3 window manager
      dmenu   # Application launcher for i3
      i3status # Status bar for i3
      i3lock  # Screen locker for i3
      
      # Essential utilities (reduced duplication)
      htop
      
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

  # Add any custom system packages (minimal set, keep most in dev environments)
  environment.systemPackages = with pkgs; [
    git
    vim # Or your preferred editor
    wget
    curl
    # Development tools that might be needed system-wide
    nix-direnv # For better direnv integration
    # Add other system-wide command-line tools
  ];

  # Firewall (optional, but recommended)
  # networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ 22 /* SSH */ ];

  system.stateVersion = "23.11"; # IMPORTANT: Set to your current NixOS version
}
