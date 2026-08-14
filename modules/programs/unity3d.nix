{ den, ... }:
{
  den.aspects.unity3d = {
    nixos =
      { pkgs, lib, ... }:
      {
        # Unity Hub
        environment.systemPackages = [
          (pkgs.unityhub.override {
            extraPkgs = fhsPkgs: [
              fhsPkgs.harfbuzz
              fhsPkgs.libogg
            ];
          })
        ];

        # Required for Unity Hub login page to open in browser
        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
        };
      };

    homeManager =
      { pkgs, lib, ... }:
      let
        extra-path = with pkgs; [
          dotnetCorePackages.sdk_9_0
          dotnetPackages.Nuget
          mono
          msbuild
        ];

        rider = pkgs.jetbrains.rider.overrideAttrs (attrs: {
          postInstall = ''
            mv $out/bin/rider $out/bin/.rider-toolless
            makeWrapper $out/bin/.rider-toolless $out/bin/rider \
              --argv0 rider \
              --prefix PATH : "${lib.makeBinPath extra-path}"

            # Unity Rider plugin expects binary at /rider/bin/rider
            # and bundled files at /rider/ — link them up
            shopt -s extglob
            ln -s $out/rider/!(bin) $out/
            shopt -u extglob
          '' + attrs.postInstall or "";
        });

        desktopFile = pkgs.makeDesktopItem {
          name = "jetbrains-rider";
          desktopName = "Rider";
          exec = "\"${rider}/bin/rider\"";
          icon = "rider";
          type = "Application";
          extraConfig.NoDisplay = "true";
        };
      in
      {
        home.packages = [ rider ];

        # Unity Rider plugin looks here to find the rider binary
        home.file.".local/share/applications/jetbrains-rider.desktop".source =
          "${desktopFile}/share/applications/jetbrains-rider.desktop";
      };
  };
}
