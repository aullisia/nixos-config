{ wayfireConfig }: { config, pkgs, home-manager, vars, ... }:

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

  home-manager.users."${vars.user}" = {
    home.file.".config/wayfire.ini" = {
      source = wayfireConfig;
    };
  };
}