{ den, inputs, ... }:

{
  den.aspects.nemo = {
    homeManager = { pkgs, ... }:
    {
      home.packages = with pkgs; [
        (nemo-with-extensions.override {
          extensions = with pkgs; [
            nemo-seahorse
            nemo-preview
            nemo-compare
            nemo-image-converter
            nemo-fileroller
          ];
        })
      ];

      xdg.desktopEntries.nemo = {
        name = "Nemo";
        exec = "${pkgs.nemo-with-extensions}/bin/nemo";
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = [ "nemo.desktop" ];
          "application/x-gnome-saved-search" = [ "nemo.desktop" ];
        };
      };

      dconf.settings = {
        "org/nemo/preferences" = {
          click-policy = "double";
          date-format = "iso";
          show-advanced-permissions = true;
          show-hidden-files = true;
          show-toggle-extra-pane-toolbar = true;
          size-prefixes = "base-10";
          tooltips-in-icon-view = false;
          tooltips-in-list-view = false;
        };
        "org/cinnamon/desktop/applications/terminal" = {
          exec = "ghostty";
        };
      };
    };
  };
}