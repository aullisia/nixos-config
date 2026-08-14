# Catppuccin Mocha (lavender accent) — the "default" theme.
#
# Every field here is the full theming data for the system. Consumers read
# these via `config.modules.theme` with fallbacks, so a field can be dropped
# from a theme file without breaking anything.
{ pkgs, ... }:
{
  modules.theme = {
    name = "catppuccin-mocha-lavender";
    polarity = "dark";
    wallpaper = ../../../assets/wallpaper/catppuccin_nix_1920x1080.png;

    stylix = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      icons = {
        dark = "Yet-Another-Monochrome";
        light = "Yet-Another-Monochrome";
        package = pkgs.yet-another-monochrome-icon-set;
      };

      cursor = {
        package = pkgs.catppuccin-cursors.mochaDark;
        name = "catppuccin-mocha-dark-cursors";
        size = 24;
      };

      fonts = {
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
    };

    noctalia = {
      mode = "dark";
      source = "builtin";
      builtin = "Catppuccin";
    };

    plasma = {
      cursor = {
        theme = "catppuccin-mocha-dark-cursors";
        size = 24;
      };
      colorScheme = "CatppuccinMochaLavender";
      iconTheme = "Yet-Another-Monochrome";
      splash = {
        theme = "Catppuccin-Mocha-Lavender-Dark";
        engine = null;
      };
      windowDecorations = {
        library = "org.kde.klassy";
        theme = "Klassy";
      };
      # Installs the Catppuccin KDE look-and-feel + splash (only when set —
      # the AMOLED theme omits this and Plasma falls back to stock Breeze).
      kdeCatppuccin = {
        flavour = [ "mocha" ];
        accents = [ "lavender" ];
      };
      sddm = {
        embeddedTheme = "purple_leaves";
        headerText = "Welcome";
        blur = true;
        forceHideCompletePassword = true;
      };
      faceIcon = ../../../assets/icons/nix-lavender.png;
    };

    apps = {
      helix = {
        theme = "catppuccin_mocha-theme";
      };
      spicetify = {
        theme = "catppuccin";
        colorScheme = "mocha";
      };
      vesktop = {
        themeUrl = "https://raw.githubusercontent.com/refact0r/midnight-discord/master/themes/flavors/midnight-catppuccin-mocha.theme.css";
        themeName = "midnight-catppuccin-mocha.theme.css";
      };
      browser = {
        title = "Catppuccin Mocha";
        colors = {
          bg = "11111b";
          bg1 = "181825";
          bg2 = "1e1e2e";
          fg = "cdd6f4";
          accent = "b4befe";
          overlay = "45475a";
        };
      };
    };
  };
}
