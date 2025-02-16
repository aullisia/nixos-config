{ config, pkgs, home-manager, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
    # (import ../../modules/desktops/wayfire.nix { wayfireConfig =  ../../dotfiles/wayfire.ini; } )
    (import ../../modules/desktops/kde.nix { wallpaper = ../../dotfiles/wallpapers/ying-yi-72px.jpg;} )
  ];

  services.xserver.enable = true;

  # Nvidia graphics drivers
  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.displayManager.sddm.enable = true;

  environment.systemPackages = with pkgs; [
    # Add system wide packages
  ];
}