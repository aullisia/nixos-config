{ wallpaper, user_js }: { config, pkgs, ... }:

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
  profilePath = "uoj4h5x6.default"; # TODO find a solution to get profilePath out of profiles.ini
  
  profileDir = "${homeDir}/.librewolf/${profilePath}";
  # https://github.com/soulhotel/FF-ULTIMA
  ff-ultima = pkgs.stdenv.mkDerivation {
    name = "ff-ultima";
    src = pkgs.fetchurl {
      url = "https://github.com/soulhotel/FF-ULTIMA/releases/download/1.9.7/ffultima1.9.7.zip";
      sha256 = "sha256-mgG7KkK0VbWG0m13ZEy+nevghKlDUb0n2/DfznVbU9k=";
    };
    buildInputs = [ pkgs.unzip ];
    unpackPhase = ''
      unzip $src
    '';
    installPhase = ''
      mkdir -p $out
      cp -r * $out
      rm -f $out/theme/pic/fullmoon.png
      cp ${wallpaper} $out/theme/pic/fullmoon.png
    '';
  };
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
        "*".installation_mode = "blocked";
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
    };
  };

  home.file."${profileDir}/user.js" = {
    source = user_js;
  };

  home.file."${profileDir}/chrome" = {
    source = ff-ultima;
  };
}