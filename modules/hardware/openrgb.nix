{ den, ... }:
{
  den.aspects.openrgb.nixos =
    { pkgs, ... }:
    let
      openrgb = "${pkgs.openrgb-with-all-plugins}/bin/openrgb";

      rgbColour = "D8C8FF";

      # D_LED1 = 3 front fans
      # D_LED2 = 2 top fans + rear fan + CPU cooler
      rgbOn = pkgs.writeShellScript "rgb-on" ''
        set -eu

        ${openrgb} \
          --noautoconnect \
          --device 0 \
          --zone 0 \
          --mode Direct \
          --size 30 \
          --color ${rgbColour} \
          --device 0 \
          --zone 1 \
          --mode Direct \
          --size 30 \
          --color ${rgbColour}
      '';

      rgbOff = pkgs.writeShellScript "rgb-off" ''
        set -eu

        ${openrgb} \
          --noautoconnect \
          --device 0 \
          --zone 0 \
          --mode Direct \
          --size 30 \
          --color 000000 \
          --device 0 \
          --zone 1 \
          --mode Direct \
          --size 30 \
          --color 000000
      '';
    in
    {
      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;

        server = {
          port = 6742;
        };
      };

      services.udev.packages = [
        pkgs.openrgb-with-all-plugins
      ];

      environment.systemPackages = [
        pkgs.openrgb-with-all-plugins
      ];

      boot.kernelModules = [ "i2c-dev" ];
      hardware.i2c.enable = true;

      systemd.services.openrgb-apply-colour = {
        description = "Apply OpenRGB motherboard lighting";
        after = [ "openrgb.service" ];
        wants = [ "openrgb.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${rgbOn}";
        };
      };

      systemd.services.openrgb-shutdown-off = {
        description = "Turn off RGB lighting before shutdown/reboot";
        before = [ "shutdown.target" ];
        wantedBy = [ "shutdown.target" ];
        unitConfig.DefaultDependencies = false;

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${rgbOff}";
          TimeoutSec = 10;
        };
      };
    };
}