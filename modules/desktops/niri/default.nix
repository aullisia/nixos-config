# Uses code from https://github.com/Ly-sec/nixos

{ config, pkgs, home-manager, vars, inputs, ... }:

{
	programs.niri.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = {};

  home-manager.users."${vars.user}" = {
    imports = [
      ./settings.nix
      ./keybinds.nix
      ./rules.nix
      ./autostart.nix
      ./scripts.nix
    ];

    services.swww.enable = true;

    home.packages = with pkgs; [
      xwayland-satellite
      wl-clipboard
    ];
  };
}