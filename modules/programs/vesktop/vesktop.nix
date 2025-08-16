{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "vesktop";
      runtimeInputs = [ vesktop ];
      text = ''
        if [ "$XDG_CURRENT_DESKTOP" = "niri" ]; then
          exec vesktop --ozone-platform=x11 "$@"
        else
          exec vesktop "$@"
        fi
      '';
    })
  ];
} 