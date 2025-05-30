{ config, pkgs, lib, ... }:

{
  # Additional application configurations specific to Julisa
  # This file can be used to override or add to the dotfiles app configurations
  
  # Note: Most apps are already configured in the dotfiles modules
  # This file is here for any Julisa-specific customizations
  
  # Example: Add any additional packages Julisa might want
  # home.packages = with pkgs; [
  #   # Add any additional applications here
  # ];
  
  # Example: Override any dotfiles configurations if needed
  # programs.someapp = {
  #   enable = true;
  #   # custom settings
  # };
} 