{ den, inputs, ... }:
{
  den.aspects.librewolf.homeManager =
    { pkgs, config, lib, ... }:
let
      hexDigit = c: {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
      }.${c};

      hexPair = a: b: hexDigit a * 16 + hexDigit b;

      hexToRgb = hex: {
        r = hexPair (builtins.substring 0 1 hex) (builtins.substring 1 1 hex);
        g = hexPair (builtins.substring 2 1 hex) (builtins.substring 3 1 hex);
        b = hexPair (builtins.substring 4 1 hex) (builtins.substring 5 1 hex);
      };
      theme = config.modules.theme or { };
      browser = (theme.apps or { }).browser or { };
      browserColors = browser.colors or { };

      stylixColors = config.lib.stylix.colors or { };

      # browserColor:
      #   1. browser-specific override
      #   2. Stylix Base16 color
      #   3. hardcoded fallback
      browserColor = browserName: stylixName: default:
        browserColors.${browserName}
          or stylixColors.${stylixName}
          or default;

      bg = hexToRgb (browserColor "bg" "base00" "1e1e2e");
      bg1 = hexToRgb (browserColor "bg1" "base01" "181825");
      bg2 = hexToRgb (browserColor "bg2" "base02" "313244");
      fg = hexToRgb (browserColor "fg" "base05" "cdd6f4");

      accent = hexToRgb (browserColor "accent" "base0D" "89b4fa");

      overlay = hexToRgb (browserColor "overlay" "base03" "6c7086");
      browserTitle = browser.title or "Catppuccin Mocha";
    in
    {
      programs.librewolf = {
        enable = true;
        profiles = {
          aul = {
            isDefault = true;
            settings = {
              # Privacy / librewolf overrides
              "browser.tabs.inTitlebar" = 3;
              "webgl.disabled" = false;
              "privacy.resistFingerprinting" = true;
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
              "extensions.formautofill.addresses.enabled" = false;
              "extensions.formautofill.creditCards.enabled" = false;
            };
            extensions = {
              force = true;
              settings."FirefoxColor@mozilla.com".settings = {
                firstRunDone = true;
                theme = {
                  title = browserTitle;
                  images.additional_backgrounds = [
                    "${inputs.self}/assets/images/bg-000-5672c42860d5b06e1058dc477397f3ef.svg"
                  ];
                  colors = {
                    toolbar = bg;
                    toolbar_text = fg;
                    frame = bg1;
                    tab_background_text = fg;
                    toolbar_field = bg2;
                    toolbar_field_text = fg;
                    tab_line = accent;
                    popup = bg;
                    popup_text = fg;
                    button_background_active = overlay;
                    frame_inactive = bg1;
                    icons_attention = accent;
                    icons = accent;
                    ntp_background = bg1;
                    ntp_text = fg;
                    popup_border = accent;
                    popup_highlight_text = fg;
                    popup_highlight = overlay;
                    sidebar_border = accent;
                    sidebar_highlight_text = bg1;
                    sidebar_highlight = accent;
                    sidebar_text = fg;
                    sidebar = bg;
                    tab_background_separator = accent;
                    tab_loading = accent;
                    tab_selected = bg;
                    tab_text = fg;
                    toolbar_bottom_separator = bg;
                    toolbar_field_border_focus = accent;
                    toolbar_field_border = bg;
                    toolbar_field_focus = bg;
                    toolbar_field_highlight_text = bg;
                    toolbar_field_highlight = accent;
                    toolbar_field_separator = accent;
                    toolbar_vertical_separator = accent;
                  };
                };
              };
            };
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
            "FirefoxColor@mozilla.com" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/file/3643624/firefox_color-2.1.7.xpi";
              installation_mode = "force_installed";
            };
            "addon@darkreader.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/file/4535824/darkreader-4.9.110.xpi";
              installation_mode = "force_installed";
            };
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/file/4599707/bitwarden_password_manager-2025.10.0.xpi";
              installation_mode = "force_installed";
            };
            "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/file/4786206/styl_us-2.3.22.xpi";
              installation_mode = "force_installed";
            };
            "extension@tabliss.io" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/file/3940751/tabliss-2.6.0.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };
    };
}
