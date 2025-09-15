{ config, pkgs, lib, inputs, ... }:

let
  homeDir = config.home.homeDirectory;

  extensions = import inputs.nixpkgs {
    inherit (pkgs) system;
    config.allowUnfree = true;
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };

  my-vscode = extensions.vscode-with-extensions.override {
    vscode = extensions.vscode;
    vscodeExtensions = with extensions.vscode-marketplace; [
      bbenoist.nix
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      leonardssh.vscord
      dbaeumer.vscode-eslint
      ms-toolsai.jupyter
      ritwickdey.liveserver
      ms-vsliveshare.vsliveshare
      esbenp.prettier-vscode
      ms-python.vscode-pylance
      ms-python.python
      ms-python.debugpy
      theqtcompany.qt-core
      theqtcompany.qt-qml
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.remote-explorer
      roblox-ts.vscode-roblox-ts
      svelte.svelte-vscode
      ms-vscode-remote.vscode-remote-extensionpack
    ];
  };
in {
  home.packages = [
    my-vscode
  ];

  # TODO: settings.json
  home.activation.copyVSCodeArgv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cp -f ${./argv.json} "${homeDir}/.vscode/argv.json"
  '';
}
