{
  config,
  pkgs,
  ...
}:

{
  programs.regreet = {
    enable = true;

    cageArgs = [ "-s" ];

    settings = {
      env = {};

      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];

        x11_prefix = [ "/usr/bin/env" "niri-session" ];
      };

      appearance = {
        greeting_msg = "Welcome back!";
      };

      widget = {
        clock = {
          format = "%a %H:%M";
          resolution = "500ms";
          timezone = "Europe/Brussels";
          label_width = 150;
        };
      };
    };
  };
}