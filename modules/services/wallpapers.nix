{ config, lib, self, ... }:

let
  homeDir = config.home.homeDirectory;

  wallpaperDir = "${self}/rsc/wallpapers";
  wallpaperTarget = "${homeDir}/Pictures/Wallpapers";
in {
  home.activation.copyWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${wallpaperTarget}"
    cp -n -r "${wallpaperDir}/." "${wallpaperTarget}/"
  '';
}