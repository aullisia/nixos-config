{ den, inputs, ... }:
{
  den.aspects.b660 = {
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
      # den.aspects.ssh
      den.aspects.swap
      den.aspects.impermanence
    ];

    nixos =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ (inputs.self + "/hosts/b660/hardware-configuration.nix") ];

        # Host policy skeleton.  Machine specifics (CPU vendor, kernel, storage,
        # GPU, firmware, UUIDs) are intentionally absent: the installer writes
        # the real hardware-configuration.nix from the actual machine, and
        # kernel / GPU choices are a host-policy decision.
      };
  };
}
