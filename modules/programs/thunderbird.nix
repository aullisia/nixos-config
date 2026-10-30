{ den, inputs, ... }:
{
  den.aspects.thunderbird.homeManager =
    { pkgs, config, ... }:
    {
      programs.thunderbird = {
        enable = true;
      };
    };
}