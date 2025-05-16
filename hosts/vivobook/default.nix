{ config, pkgs, home-manager, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
    # (import ../../modules/desktops/gnome.nix)
    # (import ../../modules/desktops/wayfire.nix { wayfireConfig =  ../../dotfiles/wayfire.ini; } )
  ];

  # KDE
  services.xserver.enable = true; # optional
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    elisa
    gwenview
    okular
    kate
    khelpcenter
    spectacle
    ffmpegthumbs
    krdp
  ];

  # Services for Gnome
  # services.xserver.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  
  # Graphics Drivers
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      mesa
    ];
  };

  programs.bash.shellAliases = {
    nixb = "sudo nixos-rebuild switch --flake .#vivobook";
    ff = "fastfetch";
  };

  environment.sessionVariables = rec {
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"; # Allow godot mono to work
  };

  # Wireguard VPN
  networking.wg-quick.interfaces = {
    wg0 = {
      configFile = "/etc/wireguard/wg0.conf";
      autostart = false;
    };
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # direnv
  programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    silent = false;
    loadInNixShell = true;
    direnvrcExtra = "";
    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    dotnet-sdk_9
    wireguard-tools

    (python311.withPackages (ps: with ps; [
      numpy
      scipy
      jupyterlab
      pandas
      statsmodels
      scikitlearn
      ipykernel
      conda
      # langdetect
    ]))

    # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
    (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
      pkgs.buildFHSUserEnv (base // {
      name = "fhs";
      targetPkgs = pkgs: 
        # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
        # lacking many basic packages needed by most software.
        # Therefore, we need to add them manually.
        #
        # pkgs.appimageTools provides basic packages required by most software.
        (base.targetPkgs pkgs) ++ (with pkgs; [
          pkg-config
          ncurses
          # Feel free to add more packages here if needed.
        ]
      );
      profile = "export FHS=1";
      runScript = "bash";
      extraOutputsToInstall = ["dev"];
    }))
  ];

  # System flatpaks
  services.flatpak.enable = true;
  services.flatpak.packages = [
    { flatpakref = "https://dl.flathub.org/repo/appstream/org.vinegarhq.Sober.flatpakref"; sha256="sha256:15ak2i5nk64wbmswqml2cqfgidczawqybmc7pmw94yp8wcd4yv6i"; } # Roblox Player
    { flatpakref = "https://dl.flathub.org/repo/appstream/org.vinegarhq.Vinegar.flatpakref"; sha256="sha256:03l53m3hfwsqr1jbgfs67jr139zsp27nik253b8xgv3s5g59djc0"; } # Roblox Studio
    # { flatpakref = "https://dl.flathub.org/repo/appstream/org.godotengine.GodotSharp.flatpakref"; sha256="sha256:0i58wijbx20kmqz20mwip25qm7nyb8r0azx9nqzbsr3068jb97vq"; } # Godot Mono
  ];
}
