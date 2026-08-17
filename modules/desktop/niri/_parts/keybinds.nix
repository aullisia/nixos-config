# Niri keybinds. Noctalia IPC uses v5 syntax (`noctalia msg …`).
{
  config,
  pkgs,
  ...
}:

let
  app = import ./applications.nix { inherit pkgs; };
in
{
  programs.niri.settings.binds = with config.lib.niri.actions; {
    # Noctalia (v5) — panels, launcher, settings
    "super+d".action = spawn [ "noctalia" "msg" "panel-toggle" "launcher" ];
    "super+s".action = spawn [ "noctalia" "msg" "panel-toggle" "control-center" ];
    "super+comma".action = spawn [ "noctalia" "msg" "settings-toggle" ];
    "alt+tab".action = spawn [ "noctalia" "msg" "window-switcher" ];

    # Apps
    "super+q".action = close-window;
    "super+b".action = spawn app.browser;
    "super+t".action = spawn app.terminal;
    "super+E".action = spawn app.fileManager;

    "super+w" = {
      action = spawn [ "noctalia" "msg" "panel-toggle noctalia/mpvpaper:picker" ];
      hotkey-overlay = { title = "animated wallpaper"; };
    };

    "super+o" = { action = toggle-overview; "repeat" = false; };

    # Focus
    "super+left" = { action = focus-column-left; };
    "super+down" = { action = focus-workspace-down; };
    "super+up" = { action = focus-workspace-up; };
    "super+right" = { action = focus-column-right; };

    # Move
    "super+shift+left" = { action = move-column-left; };
    "super+shift+right" = { action = move-column-right; };
    "super+shift+down" = { action = move-column-to-workspace-down; };
    "super+shift+up" = { action = move-column-to-workspace-up; };

    # Column / window sizing
    "super+r" = { action = switch-preset-column-width; };
    "super+shift+r" = { action = switch-preset-window-height; };
    "super+ctrl+r" = { action = reset-window-height; };

    "super+bracketleft" = { action = consume-or-expel-window-left; };
    "super+bracketright" = { action = consume-or-expel-window-right; };

    "super+a" = { action = toggle-window-floating; };
    "super+v" = { action = toggle-window-floating; };
    "super+f" = { action = maximize-column; };
    "super+shift+f" = { action = fullscreen-window; };

    # Screenshot
    "print" = { action = spawn [ "sh" "-c" ''
      base=~/Pictures/Screenshots
      dir="$base/$(date +%Y-%m)"
      mkdir -p "$dir"
      file="$dir/screenshot-$(date +%Y%m%d_%H%M%S).png"
      grim -g "$(slurp)" "$file" && wl-copy < "$file"
    '' ]; };

    # Workspace switching
    "super+wheelscrolldown" = { action = focus-workspace-down; "cooldown-ms" = 150; };
    "super+wheelscrollup" = { action = focus-workspace-up; "cooldown-ms" = 150; };

    # Noctalia IPC — audio / brightness / lock
    "XF86AudioRaiseVolume".action = spawn [ "noctalia" "msg" "volume-up" ];
    "XF86AudioLowerVolume".action = spawn [ "noctalia" "msg" "volume-down" ];
    "XF86AudioMute".action = spawn [ "noctalia" "msg" "volume-mute" ];
    "XF86MonBrightnessUp".action = spawn [ "noctalia" "msg" "brightness-up" ];
    "XF86MonBrightnessDown".action = spawn [ "noctalia" "msg" "brightness-down" ];

    # Lock
    "Mod+L".action = spawn [ "noctalia" "msg" "session" "lock" ];
  };
}
