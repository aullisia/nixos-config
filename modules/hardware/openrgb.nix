{ den, ... }:
{
  den.aspects.openrgb.nixos =
    { pkgs, ... }:
    {
      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
        server = {
          port = 6742;
        };
      };
      services.udev.packages = [ pkgs.openrgb-with-all-plugins ];

      boot.kernelModules = [ "i2c-dev" ];
      hardware.i2c.enable = true;
    };
}