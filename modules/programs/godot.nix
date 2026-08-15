{ den, inputs, ... }:

{
  den.aspects.godot = {
    homeManager = { pkgs, ... }:
    {
      home.packages = with pkgs.godotPackages_4_6; [
        godot
        godot-mono
      ];
    };

    nixos = {
      # Godot Mono (C#) needs .NET globalization disabled to start without
      # crashing on missing ICU data.
      environment.sessionVariables.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
    };
  };
}