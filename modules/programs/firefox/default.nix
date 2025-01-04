{ config, pkgs, ... }:

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
  profilePath = "z0wpysvw.default";
  profileDir = "${homeDir}/.mozilla/firefox/${profilePath}";
  # https://github.com/Naezr/ShyFox
  shyFox = pkgs.fetchFromGitHub {
    owner = "Naezr";
    repo = "Shyfox";
    rev = "main";
    sha256 = "sha256-7H+DU4o3Ao8qAgcYDHVScR3pDSOpdETFsEMiErCQSA8=";
  };
in
{
  programs.firefox = {
    enable = true;
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
        "*".installation_mode = "blocked";
        "userchrome-toggle-extended@n2ezr.ru" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/userchrome-toggle-extended/latest.xpi";
          installation_mode = "force_installed";
        };
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
          installation_mode = "force_installed";
        };
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  home.file."${profileDir}/user.js" = {
    source = shyFox + "/user.js";
  };

  home.file."${profileDir}/chrome" = {
    source = shyFox + "/chrome";
  };
}