{ config, lib, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  script = ./autostart-runner.sh;
in {
  # ensure folder exists
  home.activation.createAutostartFolder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${homeDir}/.config/autostart-scripts"
  '';

  # install script into ~/.local/bin
  home.file.".local/bin/autostart-runner.sh" = {
    source = script;
    executable = true;
  };

  # add ~/.local/bin to PATH if needed
  home.sessionPath = [ "${homeDir}/.local/bin" ];
}
