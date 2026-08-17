{ den, inputs, ... }:
{
  den.aspects.niri = {
    includes = [

    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [
          # inputs.skwd-wall.nixosModules.default
        ];

        programs.niri = {
          enable = true;
          package = pkgs.niri;
        };

        # Noctalia recommended service (battery widget etc.)
        services.upower.enable = true;

        # Wayland desktop portals — screen sharing/casting in niri and GTK
        # apps. Screen cast/screenshot route through the portal to niri.
        xdg.portal = {
          enable = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-gnome
          ];
        };

        # Secret storage for browser/app logins (unlocked via PAM at greetd).
        services.gnome.gnome-keyring.enable = true;
      };

    homeManager =
      { config, pkgs, lib, ... }:
      let
        theme = config.modules.theme or { };
        noct = theme.noctalia or { };
        wall = theme.wallpaper or "${inputs.self}/assets/wallpaper/catppuccin_nix_1920x1080.png";
      in
      {
        imports = [
          inputs.niri.homeModules.niri
          ./_parts/settings.nix
          ./_parts/keybinds.nix
          ./_parts/rules.nix
          ./_parts/autostart.nix
          inputs.noctalia.homeModules.default
        ];

        programs.niri = {
          enable = true;
          package = pkgs.niri;
        };

        programs.noctalia = {
          enable = true;
          package = pkgs.noctalia;

          # Theme-defined custom palettes (e.g. the AMOLED one) are written to
          # ~/.config/noctalia/palettes/<name>.json and selected via
          # theme.source = "custom" + custom_palette below.
          customPalettes = noct.customPalettes or { };

          settings = {
            theme = {
              mode = noct.mode or "dark";
              source = noct.source or "builtin";
              builtin = noct.builtin or "Catppuccin";
              pure_black_dark = noct.pureBlackDark or false;
            }
            // lib.optionalAttrs (noct ? customPalette) { custom_palette = noct.customPalette; };

            wallpaper = {
              enabled = true;
              default.path = wall;
            };

            shell.niri_overview_type_to_launch_enabled = true;

            # Skip the first-run setup wizard / "here's how this works"
            # message on every boot (state dir is wiped by impermanence).
            shell.setup_wizard_enabled = false;

            plugins = {
              enabled = [
                "noctalia/mpvpaper"
              ];
            };
          };
        };

        home.file."Pictures/Wallpapers/${builtins.baseNameOf wall}".source = wall;

        home.packages = with pkgs; [
          gcr
          xwayland-satellite
          wl-clipboard
          grim
          slurp
          swappy
          nemo
          mpv
          mpvpaper
        ];

        services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 300;
              command = "${pkgs.noctalia}/bin/noctalia msg session lock";
            }
          ];
        };

        programs.swaylock.enable = true;
      };
  };
}
