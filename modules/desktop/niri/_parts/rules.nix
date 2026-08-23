{
  config,
  pkgs,
  ...
}: {
  programs.niri.settings = {
    layer-rules = [
      # Noctalia v5 stationary wallpaper on the backdrop (docs: Option 2)
      {
        matches = [
          {
            namespace = "^noctalia-wallpaper";
          }
        ];
        place-within-backdrop = true;
      }
      # Noctalia window switcher surface
      {
        matches = [
          {
            namespace = "^noctalia-window-switcher";
          }
        ];
      }
    ];

    window-rules = [
      # Rounded corners for all windows
      {
        matches = [ { } ];
        geometry-corner-radius = {
          top-left = 15.0;
          top-right = 15.0;
          bottom-left = 15.0;
          bottom-right = 15.0;
        };
        clip-to-geometry = true;
      }

      # Transparent windows
      {
        matches = [
          { app-id = "com.mitchellh.ghostty"; }
          { app-id = "code"; }
          { app-id = "vesktop"; }
          { app-id = "spotify"; }
          { app-id = "nemo"; }
        ];
        opacity = 0.88;
        draw-border-with-background = false;
        background-effect = {
          xray = true;
          blur = true;
        };
      }

      # Noctalia settings window floats
      {
        matches = [
          {
            app-id = "dev.noctalia.Noctalia";
          }
        ];
        open-floating = true;
      }

      # Spotify
      {
        matches = [
          { app-id = "spotify"; }
        ];
        open-on-workspace = "music";
        open-maximized = true;
      }

      # Vesktop
      {
        matches = [
          { app-id = ''vesktop''; }
        ];
        open-on-workspace = "chat";
        open-maximized = true;
      }

      # Steam notification
      {
        matches = [
          {
            app-id = "steam";
            title = ''^notificationtoasts_\d+_desktop$'';
          }
        ];
        default-floating-position = {
          x = 10;
          y = 10;
          relative-to = "bottom-right";
        };
        open-focused = false;
      }

      # Satty
      {
        matches = [
          {
            app-id = "org.satty.satty";
          }
        ];

        open-floating = true;
        open-fullscreen = true;
        open-focused = true;
      }
    ];
  };
}
