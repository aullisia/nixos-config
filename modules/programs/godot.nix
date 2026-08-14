{ den, inputs, ... }:

{
  den.aspects.godot.homeManager = { pkgs, ... }:
  {
    home.packages = with pkgs.godotPackages_4_6; [
      godot
      godot-mono
    ];
  };
}