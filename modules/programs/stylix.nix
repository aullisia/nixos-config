{ config, pkgs, lib, self, stylix, ... }:
{
  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.base16Scheme = toString (builtins.path {
    path = "${self}/rsc/config/themes/base16/catppuccin-mocha.yaml";
  });

  stylix.enableReleaseChecks = false;
}