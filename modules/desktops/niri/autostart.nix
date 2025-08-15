{ lib, pkgs, ... }:

{
  programs.niri.settings.spawn-at-startup = [
    #{ command = ["systemctl" "--user" "start" "hyprpolkitagent"]; }
    #{ command = ["arrpc"]; }
    { command = ["xwayland-satellite"]; }
    { command = ["bash" "-c" "swww-daemon & swww img ~/nixos-config/dotfiles/wallpapers/frier.png --transition-type center"]; }
    #{ command = ["qs"]; }
    { command = ["vesktop"]; }
    { command = ["spotify"]; }
    #{ command = ["swww-daemon"]; }
    #{ command = ["${pkgs.swaybg}/bin/swaybg" "-o" "DP-1" "-i" "/home/lysec/nixos/assets/wallpapers/clouds.png" "-m" "fill"]; }
    #{ command = ["sh" "-c" "swww-daemon & swww img /home/lysec/nixos/wallpapers/cloud.png"]; }
  ];
}