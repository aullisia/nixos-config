{ wallpaper }: { config, pkgs, ... }:

# Firefox configurations
# Themes can NOT be set declaratively for FF-ULTIMA or I haven't found a way to do it yet so:
# Sideberry theme installation https://github.com/soulhotel/FF-ULTIMA/wiki/Sidebery-Configuration

# TODO Librewolf configurations https://librewolf.net/docs/settings/

let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  
  homeDir = builtins.getEnv "HOME";
  profilePath = "5dmmgw43.default"; # TODO find a solution to get profilePath out of profiles.ini
  
  profileDir = "${homeDir}/.librewolf/${profilePath}";
  # https://github.com/soulhotel/FF-ULTIMA
  # ff-ultima = pkgs.stdenv.mkDerivation {
  #   name = "ff-ultima";
  #   src = pkgs.fetchurl {
  #     url = "https://github.com/soulhotel/FF-ULTIMA/releases/download/2.0/ffultima2.0.zip";
  #     sha256 = "sha256-rN5K1b22/8mB9fXF2Z1SauUlfzGfW7/R7HW44zPW2gg=";
  #   };
  #   buildInputs = [ pkgs.unzip ];
  #   unpackPhase = ''
  #     unzip $src
  #   '';
  #   installPhase = ''
  #     mkdir -p $out
  #     cp -r * $out
  #     rm -f $out/theme/pic/fullmoon.png
  #     cp ${wallpaper} $out/theme/pic/fullmoon.png
  #   '';
  # };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;

      EnableTrackingProtection = {
        Value= true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      DontCheckDefaultBrowser = true;

      ExtensionSettings = {
        "*".installation_mode = "allowed";
        # "userchrome-toggle-extended@n2ezr.ru" = {
        #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/userchrome-toggle-extended/latest.xpi";
        #   installation_mode = "force_installed";
        # };
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
          installation_mode = "force_installed";
        };
        # "uBlock0@raymondhill.net" = {
        #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        #   installation_mode = "force_installed";
        # };
        # "jid1-MnnxcxisBPnSXQ@jetpack" = {
        #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
        #   installation_mode = "force_installed";
        # };
      };

      Preferences = {
        /* color schemes */
        "user.theme.dark.a"                  = lock-true;
        "user.theme.light.a"                 = lock-true;
        "user.theme.adaptive"                = lock-false;
        "user.theme.dark.catppuccin"         = lock-false;
        "user.theme.dark.catppuccin-frappe"  = lock-false;
        "user.theme.dark.catppuccin-mocha"   = lock-false;
        "user.theme.dark.gruvbox"            = lock-false;
        "user.theme.light.gruvbox"           = lock-false;
        "user.theme.dark.midnight"           = lock-false;

        /* titlebar and tabs */
        "ultima.disable.alltabs.button"                = lock-true;
        "ultima.disable.windowcontrols.button"         = lock-false;
        "ultima.disable.verticaltab.bar"               = lock-false;
        "ultima.disable.verticaltab.bar.withindicator" = lock-true;
        "ultima.xstyle.bookmarks.autohide"             = lock-true;
        "ultima.xstyle.bookmarks.centered"             = lock-false;
        "ultima.spacing.compact.tabs"                  = lock-true;
        "ultima.tabs.belowURLbar"                      = lock-true;
        "browser.tabs.tabMinWidth"                     = { Value = 0; Status = "locked"; };
        "sidebar.animation.expand-on-hover.duration-ms"= { Value = 120; Status = "locked"; };
        "sidebar.expandOnHover"                        = lock-true;

        /* sidebar */
        "ultima.sidebar.autohide"                     = lock-false;
        "ultima.sidebar.seperator"                    = lock-false;
        "ultima.sidebery.autohide"                    = lock-true;
        "ultima.sidebery.expandon.inactive.windows"   = lock-false;
        "ultima.xstyle.sidebar.theming"               = lock-true;

        /* url bar */
        "ultima.navbar.autohide"      = lock-false;
        "ultima.urlbar.suggestions"   = lock-true;
        "ultima.urlbar.centered"      = lock-true;
        "ultima.urlbar.hidebuttons"   = lock-false;
        "ultima.xstyle.urlbar"        = lock-false;

        /* extra theming */
        "ultima.theme.extensions"     = lock-true;
        "ultima.theme.icons"          = lock-true;
        "ultima.theme.menubar"        = lock-true;
        "ultima.theme.color.swap"     = lock-false;

        /* alternate styles */
        "ultima.spacing.compact"            = lock-false;
        "ultima.xstyle.tabgroups.i"         = lock-true;
        "ultima.xstyle.tabgroups.ii"        = lock-false;
        "ultima.xstyle.tabgroups.with.colormix" = lock-false;
        "ultima.xstyle.containertabs.i"     = lock-false;
        "ultima.xstyle.containertabs.ii"    = lock-false;
        "ultima.xstyle.containertabs.iii"   = lock-true;
        "ultima.xstyle.pinnedtabs.i"        = lock-false;
        "ultima.xstyle.newtabbutton.ontop.i"= lock-false;
        "ultima.xstyle.newtabbutton.ontop.ii"= lock-false;
        "ultima.xstyle.newtab.rounded"      = lock-false;
        "ultima.xstyle.private"             = lock-false;
        "ultima.xstyle.bookmarks.fading"    = lock-false;


        /* override wallpapers */
        "user.theme.wallpaper.catppuccin"           = lock-false;
        "user.theme.wallpaper.catppuccin-mocha"    = lock-false;
        "user.theme.wallpaper.catppuccin-frappe"   = lock-false;
        "user.theme.wallpaper.dusky"               = lock-false;
        "user.theme.wallpaper.fullmoon"            = lock-false;
        "user.theme.wallpaper.green"               = lock-false;
        "user.theme.wallpaper.gruvbox"             = lock-false;
        "user.theme.wallpaper.gruvbox.flowers"     = lock-false;
        "user.theme.wallpaper.gruvbox.light"       = lock-false;
        "user.theme.wallpaper.midnight"            = lock-false;
        "user.theme.wallpaper.midnight2"           = lock-false;
        "user.theme.wallpaper.seasonal"            = lock-false;
        "user.theme.wallpaper.seasonal2"           = lock-false;

        /* new tab page */
        "browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled"           = lock-false;
        "browser.newtabpage.activity-stream.newtabWallpapers.customWallpaper.enabled" = lock-true;
        "browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar"    = lock-false;

        /* extra configs */
        "ultima.enable.nightly.config" = lock-false;
        "ultima.enable.js.config"      = lock-false;

        /* extra necessary */
        "ultima.xstyle.highlight.aboutconfig"             = lock-true;
        "browser.aboutConfig.showWarning"                 = lock-false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;
        "devtools.debugger.remote-enabled"                = lock-true;
        "devtools.chrome.enabled"                         = lock-true;
        "devtools.debugger.prompt-connection"             = lock-false;
        "svg.context-properties.content.enabled"          = lock-true;
        "layout.css.has-selector.enabled"                 = lock-true;
        "widget.gtk.ignore-bogus-leave-notify"            = { Value = 1; Status = "locked"; };
        "widget.gtk.rounded-bottom-corners.enabled"       = lock-true;
        "widget.gtk.native-context-menus"                 = lock-false;
        "sidebar.verticalTabs"                            = lock-true;

        /* extra recommended */
        "toolkit.tabbox.switchByScrolling"  = lock-false;
        "browser.tabs.groups.enabled"       = lock-true;
        "browser.tabs.hoverPreview.enabled" = lock-true;
        "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = lock-false;

        /* accessibility */
        "findbar.highlightAll"                          = lock-true;
        "browser.tabs.insertAfterCurrent"               = lock-true;
        "browser.search.context.loadInBackground"       = lock-true;
        "browser.bookmarks.openInTabClosesMenu"         = lock-false;
        "full-screen-api.transition-duration.enter"     = "0 0";
        "full-screen-api.transition-duration.leave"     = "0 0";
        "full-screen-api.warning.timeout"               = 0;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
        "network.http.max-connections"                  = 300;
        "browser.urlbar.suggest.calculator"             = lock-false;
        "apz.overscroll.enabled"                       = lock-true;
        "general.smoothScroll"                         = lock-true;
        "general.smoothScroll.msdPhysics.enabled"       = lock-true;

        /* privacy */
        "browser.send_pings" = lock-false;
        "dom.event.clipboardevents.enabled" = lock-true;
        "dom.battery.enabled" = lock-false;
        "extensions.pocket.enabled" = lock-false;
        "datareporting.healthreport.uploadEnabled" = lock-false;
        "privacy.clearOnShutdown.cookies" = lock-false;
        "privacy.clearOnShutdown.cache" = lock-false;
      };
    };
  };

  # home.file."${profileDir}/chrome" = {
  #   source = ff-ultima;
  # };
}
