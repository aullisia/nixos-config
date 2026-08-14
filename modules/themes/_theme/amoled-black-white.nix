# AMOLED Black & White — a pure-black/white theme.
#
# Deliberately omits several fields to show the fallback behaviour: fonts,
# KDE Catppuccin theming, the face icon and the per-app themes are left unset,
# so Stylix/Plasma/app modules use their built-in defaults (a theme only needs
# to specify what differs from the default look).
{ pkgs, ... }:
{
  modules.theme = {
    name = "amoled-black-white";
    polarity = "dark";
    wallpaper = ../../../assets/wallpaper/amoled_black_1920x1080.png;

    stylix = {
      # Inline base16 scheme — pure black background, white foreground,
      base16Scheme = {
        base00 = "000000";
        base01 = "111111";
        base02 = "1a1a1a";
        base03 = "2e2e2e";
        base04 = "808080";
        base05 = "ffffff";
        base06 = "e6e6e6";
        base07 = "ffffff";
        base08 = "d0d0d0";
        base09 = "b3b3b3";
        base0A = "e6e6e6";
        base0B = "ffffff";
        base0C = "d9d9d9";
        base0D = "ffffff";
        base0E = "cccccc";
        base0F = "999999";
      };

      icons = {
        dark = "Yet-Another-Monochrome";
        light = "Yet-Another-Monochrome";
        package = pkgs.yet-another-monochrome-icon-set;
      };

      cursor = {
        package = pkgs.whitesur-cursors;
        name = "WhiteSur-cursors";
        size = 24;
      };
      # fonts intentionally omitted → falls back to the defaults in stylix.nix
    };

    noctalia = {
      mode = "dark";
      source = "custom";
      # Custom palette defined below → written to
      # ~/.config/noctalia/palettes/amoled-black-white.json by the Noctalia
      # module and selected via theme.source = "custom" + custom_palette.
      customPalette = "amoled-black-white";
      # Force pure-black surfaces regardless of elevation.
      pureBlackDark = true;

      customPalettes = {
        "amoled-black-white" = {
          dark = {
            primary = "#ffffff";
            onPrimary = "#000000";
            secondary = "#e0e0e0";
            onSecondary = "#000000";
            tertiary = "#d4d4d4";
            onTertiary = "#000000";
            error = "#e0e0e0";
            onError = "#000000";
            surface = "#000000";
            onSurface = "#ffffff";
            surfaceVariant = "#1c1c1c";
            onSurfaceVariant = "#e0e0e0";
            outline = "#666666";
            shadow = "#000000";
            hover = "#2a2a2a";
            onHover = "#ffffff";

            terminal = {
              normal = {
                black = "#000000";
                red = "#d0d0d0";
                green = "#e6e6e6";
                yellow = "#f2f2f2";
                blue = "#ffffff";
                magenta = "#cccccc";
                cyan = "#d9d9d9";
                white = "#ffffff";
              };
              bright = {
                black = "#3a3a3a";
                red = "#e6e6e6";
                green = "#f2f2f2";
                yellow = "#ffffff";
                blue = "#ffffff";
                magenta = "#e0e0e0";
                cyan = "#ececec";
                white = "#ffffff";
              };
              foreground = "#ffffff";
              background = "#000000";
              cursor = "#ffffff";
              cursorText = "#000000";
              selectionFg = "#000000";
              selectionBg = "#ffffff";
            };
          };
        };
      };
    };

    plasma = {
      cursor = {
        theme = "WhiteSur-cursors";
        size = 24;
      };
      colorScheme = "BreezeDark";
      iconTheme = "Yet-Another-Monochrome";
      splash = {
        theme = "Breeze";
        engine = null;
      };
      windowDecorations = {
        library = "org.kde.klassy";
        theme = "Klassy";
      };
      # kdeCatppuccin omitted → Plasma uses stock Breeze theming
      sddm = {
        embeddedTheme = "purple_leaves";
        headerText = "Welcome";
        blur = true;
        forceHideCompletePassword = true;
      };
      # faceIcon omitted → falls back to the default icon
    };

    apps = {
      browser = {
        title = "AMOLED Black & White";
      };
      # helix/spicetify/vesktop omitted → apps use their catppuccin defaults
    };
  };
}
