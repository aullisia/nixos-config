{ wayfireConfig }: { config, pkgs, home-manager, ... }:

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

  home-manager.users.aul = {
    home.file.".config/wayfire.ini" = {
      source = wayfireConfig;
    };
  };
}