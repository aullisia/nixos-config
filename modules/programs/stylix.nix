{ config, pkgs, lib, self, stylix, ... }:
{
  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.base16Scheme = toString (builtins.path {
    path = ../../dotfiles/themes/base16/catppuccin-mocha.yaml;
  });

  stylix.enableReleaseChecks = false;
}