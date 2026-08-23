{ den, inputs, ... }:
{
  den.aspects.jetbrains.homeManager =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        jetbrains-toolbox
        jetbrains.clion
        jetbrains.idea
        jetbrains.rider
        jetbrains.webstorm
      ];
    };
}