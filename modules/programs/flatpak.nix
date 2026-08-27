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

            overrides = {
              "org.vinegarhq.Sober" = {
                Context = {
                  filesystems = [
                    "xdg-run/app/com.discordapp.Discord:create"
                    "xdg-run/discord-ipc-0"
                  ];
                };
              };
            };
          };

          systemd.user.services.arrpc-flatpak-bridge = {
            Unit = {
              Description = "Bridge arRPC socket for Flatpak Discord RPC";
              After = [ "arrpc.service" ];
            };
            Service = {
              Type = "oneshot";
              ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %t/app/com.discordapp.Discord";
              ExecStart = "${pkgs.coreutils}/bin/ln -sf %t/discord-ipc-0 %t/app/com.discordapp.Discord/discord-ipc-0";
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          };
        };
    };
}
