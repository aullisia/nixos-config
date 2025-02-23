{ config, pkgs, home-manager, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
    (import ../../modules/desktops/gnome.nix)
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

  environment.systemPackages = with pkgs; [
    dotnet-sdk_9
  ];
}