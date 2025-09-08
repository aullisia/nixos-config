{ pkgs, lib, config, ... }:

let
  homeDir = config.home.homeDirectory;
  walkerConfigSource = ./config.toml;
  walkerThemesSource = ./themes;
in {
  home.packages = with pkgs; [
    walker
  ];

  home.activation.overwriteWalkerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${homeDir}/.config/walker"

    cp "${walkerConfigSource}" "${homeDir}/.config/walker/config.toml"

    rm -rf "${homeDir}/.config/walker/themes"
    cp -r "${walkerThemesSource}" "${homeDir}/.config/walker/themes"

    chown -R "${config.home.username}:users" "${homeDir}/.config/walker"

    chmod 600 "${homeDir}/.config/walker/config.toml"
    chmod 755 "${homeDir}/.config/walker/themes"
    chmod 600 "${homeDir}/.config/walker/themes/"*
  '';
}