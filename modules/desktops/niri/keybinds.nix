{ lib, config, pkgs, ... }:

let
  apps = import ./applications.nix { inherit pkgs; };

in {
  programs.niri.settings.binds = with config.lib.niri.actions; let
    pactl = "${pkgs.pulseaudio}/bin/pactl";

    volume-up = spawn pactl [ "set-sink-volume" "@DEFAULT_SINK@" "+5%" ];
    volume-down = spawn pactl [ "set-sink-volume" "@DEFAULT_SINK@" "-5%" ];
  in {

    # Quickshell Keybinds Start
    "super+Control+Return".action = spawn ["qs" "ipc" "call" "globalIPC" "toggleLauncher"];
    # Quickshell Keybinds End

    # "xf86audioraisevolume".action = volume-up;
    # "xf86audiolowervolume".action = volume-down;

    # "control+super+xf86audioraisevolume".action = spawn "brightness" "up";
    # "control+super+xf86audiolowervolume".action = spawn "brightness" "down";

    "super+q".action = close-window;
    "super+b".action = spawn apps.browser;
    "super+t".action = spawn apps.terminal;
    "super+d".action = spawn apps.appLauncher;
    "super+E".action = spawn apps.fileManager;

    "super+o" = { action = toggle-overview; "repeat" = false; };

    "super+left"  = { action = focus-column-left; };
    "super+down"  = { action = focus-workspace-down; };
    "super+up"    = { action = focus-workspace-up; };
    "super+right" = { action = focus-column-right; };

    "super+shift+left"  = { action = move-column-left; };
    "super+shift+right" = { action = move-column-right; };
    "super+shift+down"  = { action = move-column-to-workspace-down; };
    "super+shift+up"    = { action = move-column-to-workspace-up; };

    "super+r" = { action = switch-preset-column-width; };
    "super+shift+r" = { action = switch-preset-window-height; };
    "super+ctrl+r" = { action = reset-window-height; };

    #"print" = { action = spawn ["sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"]; };
    "print" = { action = spawn ["sh" "-c" ''
      base=~/Pictures/Screenshots
      dir="$base/$(date +%Y-%m)"
      mkdir -p "$dir"
      file="$dir/screenshot-$(date +%Y%m%d_%H%M%S).png"
      grim -g "$(slurp)" "$file" && wl-copy < "$file"
    '']; };

    # "ctrl+print" = { action = screenshot-screen; };
    # "alt+print" = { action = screenshot-window; };

    "super+wheelscrolldown" = { action = focus-workspace-down; "cooldown-ms" = 150; };
    "super+wheelscrollup"   = { action = focus-workspace-up;   "cooldown-ms" = 150; };

    "super+bracketleft"  = { action = consume-or-expel-window-left; };
    "super+bracketright" = { action = consume-or-expel-window-right; };

    "super+a" = { action = toggle-window-floating; };
    "super+f" = { action = maximize-column; };
    "super+shift+f" = { action = fullscreen-window; };
    "super+v" = { action = toggle-window-floating; };

    ## Noctalia
    #Volume
    "XF86AudioRaiseVolume".action.spawn = [
      "noctalia-shell" "ipc" "call" "volume" "increase"
    ];
    "XF86AudioLowerVolume".action.spawn = [
      "noctalia-shell" "ipc" "call" "volume" "decrease"
    ];
    "XF86AudioMute".action.spawn = [
      "noctalia-shell" "ipc" "call" "volume" "muteOutput"
    ];

    # Brightness
    "XF86MonBrightnessUp".action.spawn = [
      "noctalia-shell" "ipc" "call" "brightness" "increase"
    ];
    "XF86MonBrightnessDown".action.spawn = [
      "noctalia-shell" "ipc" "call" "brightness" "decrease"
    ];

    # Lock screen
    "Mod+L".action.spawn = [
      "noctalia-shell" "ipc" "call" "lockScreen" "lock"
    ];
  };
}