{ config, pkgs, ... }:
{
  imports = [
    ./vesktop.nix
    ./system24-catppuccin-mocha.nix
  ];
} 