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
          # echo $XDG_DATA_DIRS | tr ':' '\n' | xargs -I {} find -L {}/applications -name "*.desktop" 2>/dev/null | xargs -n 1 basename | sed 's/\.desktop$//' | sort -u
          { app-id = "com.mitchellh.ghostty"; }
          { app-id = "code"; }
          { app-id = "clion"; }
          { app-id = "idea"; }
          { app-id = "rider"; }
          { app-id = "webstorm"; }
          { app-id = "vesktop"; }
          { app-id = "obsidian"; }
          { app-id = "org.ferdium.Ferdium"; }
          { app-id = "spotify"; }
          { app-id = "nemo"; }
          { app-id = "mullvad-vpn"; }
          { app-id = "blueman-manager"; }
          { app-id = "org.gnome.FileRoller"; }
          { app-id = "qdirstat"; }
          { app-id = "org.openrgb.OpenRGB"; }
          { app-id = "org.kde.kdeconnect.app"; }
          { app-id = "steam"; }
          { app-id = "com.heroicgameslauncher.hgl"; }
          { app-id = "app.twintaillauncher.ttl"; }
          { app-id = "audacity"; }
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

      {
        matches = [
          { app-id = "org.vinegarhq.Sober"; }
        ];

        open-fullscreen = true;
      }

      # Satty
      {
        matches = [
          { app-id = "com.gabm.satty"; }
        ];

        open-floating = true;
        open-focused = true;
        open-fullscreen = false;
        default-column-width = { proportion = 1.0; };
        default-window-height = { proportion = 1.0; };
        default-floating-position = {
          x = 0;
          y = 0;
          relative-to = "top-left";
        };
      }
    ];
  };
}
