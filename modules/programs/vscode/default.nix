{ config, pkgs, lib, inputs, ... }:

let
  homeDir = config.home.homeDirectory;
in {
  home.packages = with pkgs; [
    vscode
  ];

  home.activation.copyVSCodeArgv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cp -f ${./argv.json} "${homeDir}/.vscode/argv.json"
  '';
}
