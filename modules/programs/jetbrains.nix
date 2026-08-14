{ den, inputs, ... }:
{
  den.aspects.jetbrains.homeManager =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        jetbrains-toolbox
        # JetBrains IDEs commented out while on the throwaway VM to keep the
        # store closure small (each IDE is 2-4 GiB unpacked). Re-enable on a
        # machine with real disk, or install individual IDEs via the toolbox
        # GUI (which writes under ~/.local/share/JetBrains, already persisted).
        # jetbrains.clion
        # jetbrains.idea
        # jetbrains.rider
        # jetbrains.webstorm
      ];
    };
}