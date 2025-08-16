# https://github.com/Ly-sec/nixos/blob/main/system/greeter/greetd.nix

{
  config,
  pkgs,
  ...
}:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember  --asterisks  --container-padding 2 --no-xsession-wrapper --cmd niri-session";
      };
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.greetd = {};

  systemd = {
    # To prevent getting stuck at shutdown
    extraConfig = "DefaultTimeoutStopSec=10s";
    services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}