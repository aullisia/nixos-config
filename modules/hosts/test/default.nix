{ den, inputs, ... }:
{
  den.aspects.test = {
    includes = [
      # Core system
      den.aspects.boot
      den.aspects.locale
      den.aspects.networking
      den.aspects.systemd
      den.aspects.users
      den.aspects.overlays
      den.aspects.nixsettings

      # Hardware
      den.aspects.kernel

      # Services
      den.aspects.ssh
      den.aspects.swap
      den.aspects.impermanence
      den.aspects.vscode-server
    ];

    nixos =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        imports = [ (inputs.self + "/hosts/test/hardware-configuration.nix") ];

        boot = {
          loader.limine = {
            enable = true;
          };
          kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
        };

        hardware = {
          firmware = [ pkgs.linux-firmware ];
          graphics = {
            enable = lib.mkDefault true;
            enable32Bit = lib.mkDefault true;
          };
          steam-hardware.enable = true;
        };

        services.power-profiles-daemon.enable = true;

        environment.systemPackages = with pkgs; [
          sbctl
          # (blender.override { rocmSupport = true; }) # commented since vm, use: cudaSupport or rocmSupport
        ];

        networking = {
          wireless.enable = lib.mkForce false;
          networkmanager.enable = lib.mkForce true;
        };
      };
  };
}