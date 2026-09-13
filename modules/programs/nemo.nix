{ den, inputs, ... }:

{
  den.aspects.nemo = {
    nixos = { pkgs, ... }:
    {
      services.udisks2.enable = true;
      services.gvfs.enable = true;

      security.polkit.enable = true;
      security.polkit.extraConfig =
        ''
          polkit.addRule(function(action, subject) {
            if (subject.user == "aul" &&
                (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
                 action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
                 action.id == "org.freedesktop.udisks2.filesystem-mount-other-seat" ||
                 action.id == "org.freedesktop.udisks2.filesystem-unmount-others" ||
                 action.id == "org.freedesktop.udisks2.filesystem-unmount-other-seat")) {
              return polkit.Result.YES;
            }
          });
        '';

      services.udev.extraRules = ''
        KERNEL=="nvme[0-9]*", ENV{UDISKS_IGNORE}="1"
        KERNEL=="nvme1n1p4", ENV{UDISKS_IGNORE}="0"
      '';
    };

    homeManager = { pkgs, ... }:
    {
      home.packages = with pkgs; [
        file-roller
        udiskie
        (nemo-with-extensions.override {
          extensions = with pkgs; [
            nemo-seahorse
            nemo-preview
            nemo-fileroller
          ];

          useDefaultExtensions = true;
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
          detect-automount-open = true;
        };
        "org/cinnamon/desktop/applications/terminal" = {
          exec = "ghostty";
        };
      };
    };
  };
}