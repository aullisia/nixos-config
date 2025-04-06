{ wayfireConfig, wfShell, wfDock, ironbarConfig, ulauncherConfig, wfPanel }: { config, pkgs, home-manager, vars, ... }:

# Helpful recourses:
# https://github.com/bluebyt/Wayfire-dots

{
  programs.wayfire = {
    enable = true;
    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];
  };

  environment.systemPackages = with pkgs; [
    ironbar
    # sfwbar
    ulauncher
  ];

  home-manager.users."${vars.user}" = {
    home.file.".config/wayfire.ini" = {
      source = wayfireConfig;
    };
    home.file.".config/wf-shell.ini" = {
      source = wfShell;
    };
    home.file.".config/wf-dock.css" = {
      source = wfDock;
    };
    home.file.".config/wf-panel.css" = {
      source = wfPanel;
    };
    home.file.".config/ironbar" = {
      source = ironbarConfig;
      recursive = true;
    };
    home.file.".config/ulauncher" = {
      source = ulauncherConfig;
      recursive = true;
    };
  };
}