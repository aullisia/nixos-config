{ den, inputs, ... }:
{
  den.aspects.spicetify.homeManager =
    { pkgs, config, ... }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      appTheme = ((config.modules.theme or { }).apps or { }).spicetify or { };
    in
    {
      programs.spicetify = {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
          beautifulLyrics
          catJamSynced
          copyLyrics
          fullAlbumDate
          fullAppDisplay
          groupSession
          history
          keyboardShortcut
          loopyLoop
          popupLyrics
          shuffle
        ];
        enabledCustomApps = with spicePkgs.apps; [
          marketplace
          newReleases
        ];
        theme = spicePkgs.themes.${appTheme.theme or "catppuccin"};
        colorScheme = appTheme.colorScheme or "mocha";
        wayland = true;
      };
    };
}