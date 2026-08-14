{
  programs.niri.settings = {
    prefer-no-csd = true;

    hotkey-overlay = {
      skip-at-startup = true;
    };

    layout = {
      # Transparent so the Noctalia wallpaper (placed on the backdrop) shows
      # through at all times.
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
}
