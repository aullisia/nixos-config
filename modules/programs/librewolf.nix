{ config, pkgs, ... }:

let
  cascade = builtins.fetchGit {
    url = "https://github.com/cascadefox/cascade.git";
    rev = "c0e68e86c376437510e2f7ab5b8433a9c4bd238b";
  };
in
{
  programs.librewolf = {
    enable = true;

    profiles = {
      aul = {
        isDefault = true;
        settings = {
          "webgl.disabled" = false;
          "privacy.resistFingerprinting" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "network.cookie.lifetimePolicy" = 0;
          "datareporting.healthreport.uploadEnabled" = false;
          "extensions.pocket.enabled" = false;

          "browser.urlbar.autoFill" = true;
          "browser.urlbar.dnsFirstForSingleWords" = true;
          "browser.urlbar.suggest.history" = true;
          "browser.urlbar.suggest.bookmark" = true;
          "browser.urlbar.suggest.openpage" = true;
          "browser.urlbar.suggest.searches" = true;

          "browser.search.suggest.enabled" = true;
          "browser.tabs.firefox-view" = false;
          "signon.rememberSignons" = false;
          "passwordmanager.enabled" = false;

          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.feeds.system.topstories" = false;

          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };

        userChrome = ''
        @import "includes/cascade-config.css";

        @import "includes/cascade-layout.css";
        @import "includes/cascade-responsive.css";
        @import "includes/cascade-floating-panel.css";

        @import "includes/cascade-nav-bar.css";
        @import "includes/cascade-tabs.css";
        '';
      };
    };

    policies = {
      BlockAboutConfig = true;

      DisableTelemetry = true;
      DisableFirefoxStudies = true;

      EnableTrackingProtection = {
        Value = true;
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
        # "{3c078156-979c-498b-8990-85f7987dd929}" = {
        #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
        #   installation_mode = "force_installed";
        # };
        "FirefoxColor@mozilla.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/3643624/firefox_color-2.1.7.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4535824/darkreader-4.9.110.xpi";
          installation_mode = "force_installed";
        };
        "extension@tabliss.io" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/3940751/tabliss-2.6.0.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  stylix.targets.firefox.profileNames = [ "aul" ];
  stylix.enableReleaseChecks = false;

  stylix.targets.firefox.colorTheme.enable = true;

  # home.file.".librewolf/aul/chrome".source = "${cascade}/chrome";
}