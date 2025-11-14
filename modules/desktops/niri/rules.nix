{
  config,
  pkgs,
  ...
}: {
  programs.niri.settings = {
    layer-rules = [
      {
        matches = [
          {
            namespace = "^noctalia-overview*";
          }
        ];
        place-within-backdrop = true;
      }
      # {
      #   matches = [
      #     {
      #       namespace = "^quickshell-wallpaper$";
      #     }
      #   ];
      #   #place-within-backdrop = true;
      # }
      {
        matches = [
          {
            namespace = "^quickshell-overview$";
          }
        ];
        place-within-backdrop = true;
      }
      {
        matches = [
          {
            namespace = "^swww-daemon$";
          }
        ];
        place-within-backdrop = true;
      }
    ];
    
    window-rules = [
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

      {
        matches = [{}];
        geometry-corner-radius = {
          top-left = 15.0;
          top-right = 15.0;
          bottom-left = 15.0;
          bottom-right = 15.0;
        };
        clip-to-geometry = true;
      }
    ];
  };
}