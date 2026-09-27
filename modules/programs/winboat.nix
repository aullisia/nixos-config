# WinBoat 1.0 beta from source, bundled with the Helios GPU bundle.
#
# The winboat package (pkgs/winboat/package.nix) is built from winboat-org/winboat
# @ 1.0-bleeding-edge and, when `winboat.helios.enable` is set, carries the
# Helios WDDM driver bundle so the guest gets GPU acceleration (Zink/OpenGL
# through Venus to the host AMD GPU, DXVK for D3D11, CLVK for OpenCL). Without
# the bundle the same package builds fine — GPU is simply unavailable
# ("The WinBoat build does not contain the Helios Windows bundle").
#
# The Helios bundle is an expiring GitHub Actions artifact with no stable URL;
# the retained copy lives on /persistent (kept across the btrfs root rollback
# by modules/system/impermanence.nix). It is wired up as the `helios-bundle`
# flake input (modules/flake-inputs.nix): pure flake eval cannot `builtins.path`
# absolute paths outside the repo, so a `flake = false` `path:` input is used —
# Nix copies it into the store during input resolution. Refresh it with:
#
#   gh run download 34785908809 --repo winboat-org/helios \
#     --name helios-windows-x64-22.22.288.0 --dir /persistent/opt
#
# If the bundle is replaced, re-run `nix run .#write-flake` (or `nix flake lock
# --update-input helios-bundle`) to refresh the narHash in flake.lock.
#
# First-build hashes (lib.fakeHash placeholders in pkgs/winboat/package.nix,
# pkgs/winboat/wbfreerdp.nix, pkgs/winboat/guest-server.nix) must be filled in
# per the build order in pkgs/winboat/README.md before this gets to build.
{ den, inputs, ... }:
{
  # Expose the three packages as flake outputs so hash placeholders can be
  # filled in dependency order (README in pkgs/winboat/): nix build .#wbfreerdp
  # -> .#winboat-guest-server -> .#winboat.
  perSystem =
    { lib, pkgs, config, ... }:
    let
      winboat = pkgs.callPackage (inputs.self + "/pkgs/winboat/package.nix") {
        heliosBundle = inputs.helios-bundle;
      };
    in
    {
      packages = {
        inherit winboat;
        wbfreerdp = winboat.wbfreerdp;
        winboat-guest-server = winboat.guest-server;
      };
    };

  den.aspects.winboat.nixos =
    { pkgs, lib, config, ... }:
    {
      options.winboat = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install the from-source winboat 1.0 package.";
        };

        helios = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Stage the Helios WDDM/GPU bundle into the winboat build. Loads
              the udmabuf kernel module (Helios blob zero-copy) and enables
              GPU acceleration in the guest via Mesa Zink/Venus, DXVK and CLVK.
            '';
          };

          bundle = lib.mkOption {
            type = lib.types.path;
            default = inputs.helios-bundle;
            defaultText = "inputs.helios-bundle";
            description = ''
              Store path of the extracted Helios bundle (normally the
              `helios-bundle` flake input). Set `inputs.helios-bundle` in
              modules/flake-inputs.nix to relocate it.
            '';
          };
        };
      };

      config = lib.mkIf config.winboat.enable {
        environment.systemPackages = [
          (pkgs.callPackage (inputs.self + "/pkgs/winboat/package.nix") {
            heliosBundle =
              if config.winboat.helios.enable then config.winboat.helios.bundle else null;
          })
        ];

        # udmabuf is not auto-loaded (it matches no hardware), and the Helios
        # zero-copy blob relies on it when GPU acceleration is on.
        boot.kernelModules = lib.mkIf config.winboat.helios.enable [ "udmabuf" ];
      };
    };
}