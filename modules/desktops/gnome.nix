{ config, pkgs, home-manager, ... }:

{
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    orca
    evince
    file-roller
    geary
    gnome-disk-utility
    seahorse
    sushi
    sysprof
    gnome-tour
    gnome-user-docs
    baobab
    epiphany
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    # gnome-clocks
    gnome-console
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    # gnome-system-monitor
    gnome-weather
    loupe
    # nautilus
    gnome-connections
    simple-scan
    snapshot
    totem
    yelp
    gnome-software
  ];

  environment.systemPackages = with pkgs; [
    vanilla-dmz
  ];
  home-manager.users.aul = {
    home.packages = with pkgs; [ 

    ];

    home.pointerCursor = {
      x11.enable = true;
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 24;
      gtk.enable = true;
    };
  };
}