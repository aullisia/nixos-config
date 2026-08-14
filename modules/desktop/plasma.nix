# KDE Plasma + SDDM. All theming values come from `config.modules.theme`
# (provided by modules/themes) with fallbacks; the Catppuccin KDE
# look-and-feel/splash is only installed when a theme sets
# `plasma.kdeCatppuccin` (the AMOLED theme omits it → stock Breeze).
{ den, inputs, ... }:
{
  den.aspects.plasma =
    { host, ... }:
    {
      nixos =
        { pkgs, lib, config, ... }:
        let
          theme = config.modules.theme or { };
          pl = theme.plasma or { };
          sddm = pl.sddm or { };
          wall = theme.wallpaper or "${inputs.self}/assets/wallpaper/catppuccin_nix_1920x1080.png";
          cursorName = (pl.cursor or { }).theme or (theme.stylix.cursor or { }).name or "catppuccin-mocha-dark-cursors";
          cursorSize = (pl.cursor or { }).size or 24;
          cursorPkg = (theme.stylix.cursor or { }).package or pkgs.catppuccin-cursors.mochaDark;
          kdeCatppuccin = pl.kdeCatppuccin or null;
        in
        {
          services.desktopManager.plasma6 = {
            enable = true;
          };
          services.displayManager.sddm = {
            enable = true;
            wayland.enable = true;
            theme = "sddm-astronaut-theme";
          };

          environment.plasma6.excludePackages = with pkgs; [
            kdePackages.elisa
            kdePackages.gwenview
            kdePackages.okular
            kdePackages.kate
            # kdePackages.ark
            # kdePackages.spectacle
            kdePackages.khelpcenter
            # kdePackages.qrca
          ];

          environment.systemPackages = with pkgs; [
            kdePackages.plasma-workspace-wallpapers
            kdePackages.kdegraphics-thumbnailers
            nixos-icons
            cursorPkg
            yet-another-monochrome-icon-set
            andromeda-launcher
            klassy
            jetbrains-runner

            # SDDM
            (pkgs.sddm-astronaut.override {
              embeddedTheme = sddm.embeddedTheme or "purple_leaves";
              themeConfig = {
                Background = toString (sddm.background or wall);
                Blur = sddm.blur or true;
                ForceHideCompletePassword = sddm.forceHideCompletePassword or true;
                HeaderText = sddm.headerText or "Welcome";
              };
            })
            kdePackages.qtmultimedia
          ] ++ lib.optional (kdeCatppuccin != null) (
            pkgs.catppuccin-kde.override {
              flavour = kdeCatppuccin.flavour;
              accents = kdeCatppuccin.accents;
            }
          );
        };

      homeManager =
        { pkgs, config, ... }:
        let
          theme = config.modules.theme or { };
          pl = theme.plasma or { };
          wall = theme.wallpaper or "${inputs.self}/assets/wallpaper/catppuccin_nix_1920x1080.png";
          faceIcon = pl.faceIcon or "${inputs.self}/assets/icons/nix-lavender.png";
        in
        {
          imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

          home.file.".face.icon".source = faceIcon;

          programs.plasma = {
            enable = true;
            overrideConfig = true;

            workspace = {
              cursor = {
                theme = (pl.cursor or { }).theme or (theme.stylix.cursor or { }).name or "catppuccin-mocha-dark-cursors";
                size = (pl.cursor or { }).size or 24;
              };
              theme = "default";
              colorScheme = pl.colorScheme or "CatppuccinMochaLavender";
              iconTheme = pl.iconTheme or "Yet-Another-Monochrome";
              splashScreen = {
                theme = (pl.splash or { }).theme or "Catppuccin-Mocha-Lavender-Dark";
                engine = (pl.splash or { }).engine or null;
              };
              windowDecorations = {
                library = (pl.windowDecorations or { }).library or "org.kde.klassy";
                theme = (pl.windowDecorations or { }).theme or "Klassy";
              };
              wallpaper = wall;
            };

            panels = [
              {
                location = "bottom";
                hiding = "normalpanel";
                widgets = [
                  "org.kde.plasma.panelspacer"
                  {
                    name = "com.github.eliverlara.andromedalaauncher";
                    config = {
                      General = {
                        activationIndicator = false;
                        customButtonImage = "nix-snowflake-white";
                        floating = true;
                        launcherPosition = 2;
                        useCustomButtonImage = true;
                        useSystemFontSettings = true;
                      };
                      ConfigDialog = {
                        DialogHeight = 630;
                        DialogWidth = 810;
                      };
                    };
                  }
                  # { kickoff = { sortAlphabetically = true; icon = "nix-snowflake-white"; }; }
                  { iconTasks.launchers = [
                      "applications:org.kde.dolphin.desktop"
                      "applications:com.mitchellh.ghostty.desktop"
                      "applications:librewolf.desktop"
                      "applications:vesktop.desktop"
                    ];
                  }
                  "org.kde.plasma.panelspacer"
                  { systemTray.items.shown = [
                    "org.kde.plasma.battery"
                    "org.kde.plasma.networkmanagement"
                  ]; }
                  { digitalClock = { calendar.firstDayOfWeek = "monday"; time.format = "24h"; }; }
                ];
              }
            ];

            input.keyboard = {
              numlockOnStartup = "on";
            };

            shortcuts = {
               clear-notifications = {
                name = "Clear all KDE Plasma notifications";
                key = "Meta+Shift+Backspace";
                command = "clear-kde-notifications";
              };
              launch-terminal = {
                name = "Launch Terminal";
                key = "Meta+Shift+Return";
                command = "ghostty";
              };
              launch-browser = {
                name = "Launch Brave";
                key = "Meta+Shift+B";
                command = "librewolf";
              };
            };

            kwin = {
              edgeBarrier = 0;
              cornerBarrier = false;
            };

            kscreenlocker = {
              lockOnResume = true;
              timeout = 10;
            };

            configFile = {
              baloofilerc."Basic Settings"."Indexing-Enabled" = false;
              kwinrc."org.kde.kdecoration2".ButtonsOnLeft = "SF";
              kwinrc.Desktops.Number = { value = 4; immutable = false; };

              spectaclerc.General.autoSaveImage = true;
              spectaclerc.General.clipboardGroup = "PostScreenshotCopyImage";
              spectaclerc.ImageSave.imageFilenameTemplate = "<yyyy>-<MM>/screenshot-<title>_<HH><mm><ss>";
              spectaclerc.VideoSave.videoFilenameTemplate = "<yyyy>-<MM>/vid-<title>_<HH><mm><ss>";
            };
          };

          home.packages = with pkgs; [
            plasma-panel-colorizer
            kdePackages.karousel
          ];

          # klassy
          home.file.".config/klassy/klassyrc".text = ''
            [Global]
            RefreshedConfig=6.5.3
            [Windeco]
            ButtonIconStyle=StyleSuessigKite
            ButtonShape=ShapeIntegratedRoundedRectangle
          '';

          # karousel
          home.activation.installKarousel = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            KPACKAGETOOL=${pkgs.kdePackages.kpackage}/bin/kpackagetool6
            if $KPACKAGETOOL --type=KWin/Script -l 2>/dev/null | grep -q '^karousel$'; then
              $DRY_RUN_CMD $KPACKAGETOOL --type=KWin/Script -u ${pkgs.kdePackages.karousel}/share/kwin/scripts/karousel || true
            else
              $DRY_RUN_CMD $KPACKAGETOOL --type=KWin/Script -i ${pkgs.kdePackages.karousel}/share/kwin/scripts/karousel
            fi
          '';
          programs.plasma.configFile.kwinrc."Plugins"."karouselEnabled" = false; # disable/enable karousel
        };
    };
}
