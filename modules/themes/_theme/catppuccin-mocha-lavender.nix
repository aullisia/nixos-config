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
      source = "custom";
      customPalette = "catppuccin-mocha-custom";

      customPalettes = {
        "catppuccin-mocha-custom" = {
          dark = {
            # Accents
            primary = "#b4befe";
            onPrimary = "#11111b";
            secondary = "#cba6f7";
            onSecondary = "#11111b";
            tertiary = "#f5e0dc";
            onTertiary = "#11111b";

            # Status & Alerts
            error = "#f38ba8";
            onError = "#11111b";

            # Surfaces & Backgrounds
            surface = "#1e1e2e";
            onSurface = "#cdd6f4";
            surfaceVariant = "#313244";
            onSurfaceVariant = "#bac2de";

            # Borders & Effects
            outline = "#585b70";
            shadow = "#11111b";
            hover = "#45475a";
            onHover = "#cdd6f4";

            # Built-in Terminal Scheme
            terminal = {
              normal = {
                black = "#45475a";
                red = "#f38ba8";
                green = "#a6e3a1";
                yellow = "#f9e2af";
                blue = "#89b4fa";
                magenta = "#f5c2e7";
                cyan = "#94e2d5";
                white = "#bac2de";
              };
              bright = {
                black = "#585b70";
                red = "#f38ba8";
                green = "#a6e3a1";
                yellow = "#f9e2af";
                blue = "#89b4fa";
                magenta = "#f5c2e7";
                cyan = "#94e2d5";
                white = "#a6adc8";
              };
              foreground = "#cdd6f4";
              background = "#1e1e2e";
              cursor = "#f5e0dc";
              cursorText = "#11111b";
              selectionFg = "#cdd6f4";
              selectionBg = "#585b70";
            };
          };
        };
      };
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
