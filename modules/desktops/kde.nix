{ wallpaper }: { config, pkgs, home-manager, vars, ... }:

{
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
  ];

  home-manager.users."${vars.user}" = {
    home.packages = with pkgs; [ 
      libsForQt5.qtstyleplugin-kvantum
    ];


    # home.file.".config/wayfire.ini" = {
    #   source = wayfireConfig;
    # };
  };
}