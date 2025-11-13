# Uses code from https://github.com/Ly-sec/nixos
# Uses niri-flake https://github.com/sodiboo/niri-flake contains info on fixing vscode with gnome keyring
# https://variety4me.github.io/niri_docs/Application-Issues/

{ config, pkgs, vars, inputs, ... }:

{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  
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
      pkgs.gcr
      xwayland-satellite
      wl-clipboard
      whitesur-cursors
      grim slurp swappy
    ];

    programs.swaylock.enable = true;
    services.swayidle.enable = true;
  };
}