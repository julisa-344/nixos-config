# ~/nixos-config/users/julisa/home.nix
{ pkgs, config, lib, ... }: # Added config and lib for more advanced usage

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "julisa"; # Replace with your username
  home.homeDirectory = "/home/julisa"; # Replace with your home directory

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11"; # Set to your Home Manager version (usually matches NixOS)

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  # Packages to install in your user profile.
  home.packages = with pkgs; [
    htop
    neovim
    # Add user-specific packages here, e.g., neovim, specific development tools
  ];

  # Basic configuration of git
  programs.git = {
    enable = true;
    userName = "Julisa 344";
    userEmail = "julisa.leon344@gmail.com";
  };

  # Example: Zsh configuration
  programs.zsh = {
    enable = true;
    # ohMyZsh.enable = true; # If you want Oh My Zsh
    # Add other zsh configurations here
  };
  
  # Example: i3 configuration snippet within home-manager
  # You can manage your i3 config file this way
  # home.file.".config/i3/config".source = ./i3-config; 
  # Or directly define it:
  # xsession.windowManager.i3.config = {
  #   modifier = "Mod4"; # Super key
  #   terminal = "alacritty"; # Or your preferred terminal
  #   # ... other i3 settings
  # };


  # You can also manage dotfiles by symlinking them. For example:
  # home.file.".bashrc".source = ./dotfiles/bashrc;
  # home.file.".vimrc".source = ./dotfiles/vimrc;

  # You can also manage files directly
  # home.file.".config/mycustomapp/config.json".text = '''
  # {
  #   "setting": "value"
  # }
  # ''';
}
