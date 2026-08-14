# THEME SELECTOR — switch the whole system theme by changing which theme file
# is imported here (uncomment one, comment the other). The imported file sets
# `config.modules.theme`, which Stylix, Noctalia, Plasma/SDDM and the per-app
# modules all read (with fallbacks for any field they don't find).
{ ... }:
{
  imports = [
    ./options.nix
    ./catppuccin-mocha-lavender.nix
    # ./amoled-black-white.nix
  ];
}
