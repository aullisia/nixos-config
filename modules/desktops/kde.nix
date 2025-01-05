{ wallpaper }: { config, pkgs, home-manager, ... }:

{
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
  ];

  home-manager.users.aul = {
    home.packages = with pkgs; [ 
      libsForQt5.qtstyleplugin-kvantum
    ];


    # home.file.".config/wayfire.ini" = {
    #   source = wayfireConfig;
    # };
  };
}