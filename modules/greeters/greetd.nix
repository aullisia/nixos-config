# greetd + tuigreet greeter, boots straight into niri-session.
# (regreet was flaky in the past — greetd/tuigreet is the reliable choice.)
{ den, ... }:
{
  den.aspects.greetd.nixos =
    { pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --remember --asterisks --container-padding 2 --no-xsession-wrapper --cmd \"niri-session 2>/dev/null\"";
      };

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
