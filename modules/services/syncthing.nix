{ config, vars, ... }:

{
  services.syncthing = {
    enable = true; 
    group = "users";
    user = "${vars.user}";
    dataDir = "/home/${vars.user}/Documents"; # Default folder for new synced folders
    configDir = "/home/${vars.user}/.config/syncthing"; # Folder for Syncthing's settings and keys
  };
}