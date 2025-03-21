{ config, pkgs, home-manager, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
    (import ../../modules/desktops/gnome.nix)
    # (import ../../modules/desktops/wayfire.nix { wayfireConfig =  ../../dotfiles/wayfire.ini; } )
  ];

  # Services for Gnome
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [

  ];
}
