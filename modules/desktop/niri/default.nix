{ den, inputs, ... }:
{
  den.aspects.niri = {
    includes = [
      den.aspects.nemo
    ];
    nixos =
      { pkgs, lib, ... }:
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
            shell.setup_wizard_enabled = false;

            shell.panel = {
              clipboard_placement = "attached";
              clipboard_position = "auto";
              control_center_position = "top_left";
              open_near_click_clipboard = true;
              open_near_click_session = true;
              transparency_mode = "glass";
            };

            shell.screenshot = {
              save_to_file = false;
              directory = "~/Pictures/Screenshots";
              filename_pattern = "screenshot-%Y%m%d_%H%M%S";
              copy_to_clipboard = false;

              freeze_screen = true;
              confirm_region = false;
              remember_last_region = false;
              show_cursor = false;

              pipe_to_command = true;

              pipe_command = ''
                base="$HOME/Pictures/Screenshots"
                dir="$base/$(date +%Y-%m)"
                mkdir -p "$dir"

                file="$dir/screenshot-$(date +%Y%m%d_%H%M%S).png"

                satty \
                  --filename - \
                  --output-filename "$file" \
                  --fullscreen \
                  --early-exit

                if [ -f "$file" ]; then
                  wl-copy < "$file"
                fi
              '';
            };

            shell.session = {
              actions = [
                { action = "lock"; }
                { action = "logout"; }
                { action = "lock_and_suspend"; }
                { action = "reboot"; }
                { action = "shutdown"; }
                {
                  action = "command";
                  label = "Boot Windows";
                  glyph = "brand-windows";
                  command = "sudo efibootmgr --bootnext 0000 && systemctl reboot";
                }
              ];
            };

            plugins = {
              enabled = [
                "noctalia/mpvpaper"
                "icefish/phone-operate"
                "kenn/keybind-cheatsheet"
                "noctalia/timer"
              ];
            };

            bar.default = {
              position = "top";
              background_opacity = 0.44;
              border = "on_surface_variant";
              border_width = 0.5;
              margin_edge = 12;
              margin_ends = 12; 
              radius = 18;
              padding = 5;
              widget_spacing = 4; 

              start = [ "control-center" "clock" ];
              center = [ "workspaces" "group:temps" ];
              end = [ "group:right_icons" ];

              capsule_group = [
                {
                  id = "temps";
                  fill = "surface_variant";
                  opacity = 0.5;
                  padding = 6.0;
                  members = [ "cpu" "temp" ];
                }
                {
                  id = "right_icons";
                  fill = "surface_variant";
                  opacity = 0.5;
                  padding = 6.0;
                  members = [ "tray" "clipboard" "network" "battery" "noctalia/timer:bar" "session" ];
                }
              ];
            };

            widget.network = {
              show_label = false;
            };

            widget.control-center = {
              capsule = true;
              capsule_opacity = 0.5;
              glyph = "snowflake";
            };

            widget.clock = {
              capsule = true;
              capsule_opacity = 0.5;
              format = "{:%H:%M} {:%a %d %b}"; 
              font_family = "sans-serif Bold"; 
            };

            widget.workspaces = {
              capsule = true;
              capsule_opacity = 0.5;
              show_labels = false;
              
              active_color = "primary";
              occupied_color = "secondary";
              empty_color = "tertiary";
            };

            widget.tray = { drawer = true; };
            widget.cpu = { display = "text"; stat = "cpu_temp"; visualization = "none"; };
            widget.temp = { display = "text"; stat = "gpu_temp"; visualization = "none"; };
          };
        };

        home.file."Pictures/Wallpapers/${builtins.baseNameOf wall}".source = wall;

        home.packages = with pkgs; [
          gcr
          xwayland-satellite
          wl-clipboard
          satty

          # noctalia/mpvpaper
          mpv
          mpvpaper

          # icefish/phone-operate
          scrcpy
          android-tools
          kdePackages.kdeconnect-kde
          sshfs
        ];

        xdg.mimeApps = {
          enable = true;

          defaultApplications = {
            "text/html" = [ "librewolf.desktop" ];
            "x-scheme-handler/http" = [ "librewolf.desktop" ];
            "x-scheme-handler/https" = [ "librewolf.desktop" ];
            "application/xhtml+xml" = [ "librewolf.desktop" ];

            "image/png" = [ "qimgv.desktop" ];
            "image/jpeg" = [ "qimgv.desktop" ];
            "image/gif" = [ "qimgv.desktop" ];
            "image/webp" = [ "qimgv.desktop" ];
            "image/bmp" = [ "qimgv.desktop" ];
            "image/tiff" = [ "qimgv.desktop" ];
          };
        };

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
