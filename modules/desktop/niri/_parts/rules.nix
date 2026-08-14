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
      # Noctalia settings window floats
      {
        matches = [
          {
            app-id = "dev.noctalia.Noctalia";
          }
        ];
        open-floating = true;
      }
    ];
  };
}
