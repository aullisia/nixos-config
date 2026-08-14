{ den, pkgs, ... }:
{
  den.aspects.openrgb.nixos = {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      # motherboard = "amd";
    };
    services.udev.packages = [ pkgs.openrgb-with-all-plugins ];

    boot.kernelModules = [ "i2c-dev" ];
    hardware.i2c.enable = true;
  };
}