{ den, inputs, ... }:
{
  den.aspects.noctalia-greeter.nixos =
    { pkgs, lib, config, ... }:
    let
      theme = config.modules.theme or { };
      greeter = theme.greeter or { };
      cursor = greeter.cursor or { };
      cursorPkg = ((theme.stylix or { }).cursor or { }).package or pkgs.catppuccin-cursors.mochaDark;
    in
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
      ];

      programs.noctalia-greeter = {
        enable = true;
        settings = lib.recursiveUpdate
          { session.default = "niri"; }
          (greeter // lib.optionalAttrs (greeter ? cursor) {
            cursor = cursor // { path = "${cursorPkg}/share/icons"; };
          });
      };

      environment.systemPackages = [ cursorPkg ];

      security.pam.services.greetd.enableGnomeKeyring = true;

      systemd.services.greetd.serviceConfig = {
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