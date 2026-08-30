{ den, inputs, ... }:
{
  den.aspects.overlays.nixos =
    { host, ... }:
    {
      nixpkgs = {
        #NOTE: These are overlays, i.e patches etc to overwrite pkgs
        # these are usually just holdovers until PRs get merged and built
        # into nixos-unstable branch
        overlays = [
          inputs.nix-cachyos-kernel.overlays.pinned

          (final: prev: {
            yet-another-monochrome-icon-set =
              final.callPackage
                "${inputs.self}/pkgs/yet-another-monochrome-icon-set.nix" { };

              andromeda-launcher =
                final.callPackage "${inputs.self}/pkgs/andromeda-launcher.nix" { };

              blender =
                if host.name == "auronix" then
                  inputs.blender-bin.packages.${final.stdenv.hostPlatform.system}.default
                else
                  prev.blender.override { rocmSupport = true; };
          })
        ];
      };
    };
}