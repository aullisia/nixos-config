{ den, ... }:
{
  den.aspects.locale =
    { host, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          i18n.defaultLocale = "en_GB.UTF-8";
          time.hardwareClockInLocalTime = true;
          time.timeZone = host.timezone;
        };
    };
}