# Stylix — system-wide theming (base16 scheme → colors, cursor, icons, fonts).
#
# All theme data comes from `config.modules.theme` (provided by
# modules/themes), with hard-coded fallbacks so the system still evaluates if
# the themes aspect is absent or a field is missing. Terminal colors used by
# git/lsd/zsh flow out of `config.lib.stylix.colors` automatically.
{ den, inputs, ... }:
{
  den.aspects.stylix = {
    nixos =
      { pkgs, lib, config, ... }:
      let
        theme = config.modules.theme or { };
        st = theme.stylix or { };

        defScheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        defCursor = pkgs.catppuccin-cursors.mochaDark;

        defFonts = {
          serif = {
            package = pkgs.roboto;
            name = "Roboto";
          };
          sansSerif = {
            package = pkgs.roboto;
            name = "Roboto";
          };
          monospace = {
            package = pkgs.jetbrains-mono;
            name = "JetBrains Mono";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            applications = 13;
            terminal = 16;
          };
        };
      in
      {
        imports = [ inputs.stylix.nixosModules.stylix ];

        stylix = {
          enable = true;
          autoEnable = false;
          polarity = theme.polarity or "dark";

          base16Scheme = st.base16Scheme or defScheme;

          icons = {
            enable = true;
            dark = (st.icons or { }).dark or "Yet-Another-Monochrome";
            light = (st.icons or { }).light or "Yet-Another-Monochrome";
            package = (st.icons or { }).package or pkgs.yet-another-monochrome-icon-set;
          };

          fonts = st.fonts or defFonts;

          cursor = {
            package = (st.cursor or { }).package or defCursor;
            name = (st.cursor or { }).name or "catppuccin-mocha-dark-cursors";
            size = (st.cursor or { }).size or 24;
          };

          targets = {
            # Theme the TTY/console — this is what the greetd/tuigreet
            # greeter inherits its palette from (no dedicated greetd target
            # exists; regreet is a different greeter).
            console.enable = true;
          };
        };
      };

    homeManager =
    { lib, ... }:
    {
      stylix = {
        autoEnable = false;
        enableReleaseChecks = false;

        targets = {
          kde.enable = false;
          gtk.enable = true;
          qt.enable = true;

          librewolf = {
            enable = false;
            profileNames = [ "aul" ];

            colorTheme.enable = false;
            colors.enable = true;
            fonts.enable = true;
          };

          obsidian.enable = false;
          spicetify.enable = false;
          starship.enable = true;
        };
      };
    };
  };
}
