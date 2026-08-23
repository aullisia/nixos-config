{ den, inputs, ... }:

{
  den.aspects.heroic =
    { host, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          programs.gamescope.enable = true;
          programs.gamemode.enable = true;
        };

      homeManager =
        { pkgs, ... }:
        {
          home.packages = [
            (pkgs.heroic.override {
              extraPkgs = pkgs': with pkgs'; [
                gamescope
                gamemode
              ];
            })
          ];
        };
    };
}