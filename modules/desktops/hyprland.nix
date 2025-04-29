{ config, pkgs, home-manager, vars, ... }:

{
  programs.hyprland = {
    enable = true;
  };

  home-manager.users."${vars.user}" = {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;

      settings = {
        "$mod" = "SUPER";
        bind =
          [
            "$mod, B, exec, librewolf"
            "$mod, Return, exec, alacritty"
            "$mod, Q, killactive,"
            "$mod, F, fullscreen,"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (i:
              let ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
          );
      };
    };
  };
}