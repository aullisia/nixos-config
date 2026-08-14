{ den, inputs, lib, ... }:
{
  den.aspects.flatpak =
    { host, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

          services.flatpak = {
            enable = true;
            remotes = lib.mkOptionDefault [
              {
                name = "flathub-beta";
                location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
              }
            ];
          };
        };

      homeManager =
        { pkgs, ... }:
        {
          imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

          services.flatpak = {
            enable = true;
            remotes = lib.mkOptionDefault [
              {
                name = "flathub-beta";
                location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
              }
            ];
          };
        };
    };
}
