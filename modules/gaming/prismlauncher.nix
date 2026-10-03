{ den, inputs, ... }:
{
  den.aspects.prismlauncher.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.prismlauncher.override {
          jdks = with pkgs; [
            zulu8
            zulu17
            zulu21
            zulu25
          ];
        })
      ];
    };
}