{ den, ... }:
{
  den.aspects.syncthing.homeManager =
    {
      services.syncthing = {
        enable = true;
      };
    };

  den.aspects.syncthing.nixos =
    {
      services.syncthing.openDefaultPorts = true;
    };
}