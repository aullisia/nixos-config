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
    "super+d" = {
      action = spawn [ "noctalia" "msg" "panel-toggle" "launcher" ];
      hotkey-overlay = {
        title = "application launcher";
      };
    };

    "super+s" = {
      action = spawn [ "noctalia" "msg" "panel-toggle" "control-center" ];
      hotkey-overlay = {
        title = "control center";
      };
    };

    "super+comma" = {
      action = spawn [ "noctalia" "msg" "settings-toggle" ];
      hotkey-overlay = {
        title = "Noctalia settings";
      };
    };

    "super+f1" = {
      action = spawn [
        "noctalia"
        "msg"
        "panel-toggle"
        "kenn/keybind-cheatsheet:cheatsheet"
      ];
      hotkey-overlay = {
        title = "keybind cheatsheet";
      };
    };

    "super+p" = {
      action = spawn [ "noctalia" "msg" "panel-toggle icefish/phone-operate:main" ];
      hotkey-overlay = {
        title = "phone manager";
      };
    };

    "alt+tab" = {
      action = spawn [ "noctalia" "msg" "window-switcher" ];
      hotkey-overlay = {
        title = "window switcher";
      };
    };

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
    "print" = {
      action = spawn [ "noctalia" "msg" "screenshot-region" ];
      hotkey-overlay = {
        title = "screenshot region";
      };
    };

    # Workspace switching
    "super+wheelscrolldown" = { action = focus-workspace-down; "cooldown-ms" = 150; };
    "super+wheelscrollup" = { action = focus-workspace-up; "cooldown-ms" = 150; };

    # Noctalia IPC — audio / brightness / lock
    "XF86AudioRaiseVolume" = {
      action = spawn [ "noctalia" "msg" "volume-up" ];
      hotkey-overlay = {
        title = "increase volume";
      };
    };

    "XF86AudioLowerVolume" = {
      action = spawn [ "noctalia" "msg" "volume-down" ];
      hotkey-overlay = {
        title = "decrease volume";
      };
    };

    "XF86AudioMute" = {
      action = spawn [ "noctalia" "msg" "volume-mute" ];
      hotkey-overlay = {
        title = "toggle mute";
      };
    };

    "XF86MonBrightnessUp" = {
      action = spawn [ "noctalia" "msg" "brightness-up" ];
      hotkey-overlay = {
        title = "increase brightness";
      };
    };

    "XF86MonBrightnessDown" = {
      action = spawn [ "noctalia" "msg" "brightness-down" ];
      hotkey-overlay = {
        title = "decrease brightness";
      };
    };

    "Mod+L" = {
      action = spawn [ "noctalia" "msg" "session" "lock" ];
      hotkey-overlay = {
        title = "lock screen";
      };
    };

    # GPU Screen Recorder - Noctalia
    "super+alt+r" = {
      action = spawn [ "noctalia" "msg" "plugin" "noctalia/screen_recorder:service" "all" "toggle" ];
      hotkey-overlay = {
        title = "toggle screen recording";
      };
    };

    "super+alt+s" = {
      action = spawn [ "noctalia" "msg" "plugin" "noctalia/screen_recorder:service" "all" "replay-save" ];
      hotkey-overlay = {
        title = "save replay buffer";
      };
    };

    "super+alt+p" = {
      action = spawn [ "noctalia" "msg" "plugin" "noctalia/screen_recorder:service" "all" "replay-toggle" ];
      hotkey-overlay = {
        title = "toggle replay buffer";
      };
    };
  };
}
