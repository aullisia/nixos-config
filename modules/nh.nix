{ den, lib, ... }:
{
  den.aspects.nh = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.nh ];
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
    };
}
