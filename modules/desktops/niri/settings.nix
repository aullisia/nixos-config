{ config, pkgs, ... }:

let
  hostname = builtins.getEnv "HOSTNAME";
in
{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = {
    workspaces = if hostname == "b660" then {
      "chat" = { open-on-output = "LG Electronics MP59G 706NTUWBJ126"; };
      "music" = { open-on-output = "LG Electronics MP59G 706NTUWBJ126"; };
    } else { };


      prefer-no-csd = true;

      hotkey-overlay = {
        skip-at-startup = true;
      };

      layout = {

        background-color = "#00000000";

        focus-ring = {
          enable = true;
          width = 3;
          active = {
            color = "#b4befe";
          };
          inactive = {
            color = "#acb0be";
          };
        };

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        gaps = 16;

        center-focused-column = "never";
        default-column-width = { proportion = 0.5; };

        # struts = {
        #   left = 20;
        #   right = 20;
        #   top = 20;
        #   bottom = 20;
        # };
      };

      input = {
        keyboard = {
          xkb = {
            layout = "us";
          };

          numlock = true;
        };

        touchpad = {
          click-method = "button-areas";
          dwt = true;
          dwtp = true;
          natural-scroll = true;
          scroll-method = "two-finger";
          tap = true;
          tap-button-map = "left-right-middle";
          middle-emulation = true;
          accel-profile = "adaptive";
        };

        mouse = {
          accel-speed = 0.2;
          accel-profile = "flat";
        };

        focus-follows-mouse.enable = true;
        warp-mouse-to-focus.enable = false;
      };

      outputs = if hostname == "b660" then {
        "DP-1" = {
          mode = { width = 3440; height = 1440; refresh = 164.999; };
          scale = 1.2;
          position = { x = 0; y = 0; };
        };
        "HDMI-A-1" = {
          mode = { width = 1920; height = 1080; refresh = 74.973; };
        };
      } else { };

      cursor = {
        size = 20;
        theme = "WhiteSur-cursors";
      };

      environment = {
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        DISPLAY = ":0";
      };
    };
  };
}