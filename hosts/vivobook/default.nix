{ config, pkgs, home-manager, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
    (import ../../modules/desktops/gnome.nix)
    # (import ../../modules/desktops/wayfire.nix { wayfireConfig =  ../../dotfiles/wayfire.ini; } )
  ];

  # Services for Gnome
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  
  # Graphics Drivers
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      mesa
    ];
  };

  # Wireguard VPN
  networking.wg-quick.interfaces = {
    wg0 = {
      configFile = "/etc/wireguard/wg0.conf";
      autostart = false;
    };
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];

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
    { flatpakref = "https://sober.vinegarhq.org/sober.flatpakref"; sha256="sha256:1pj8y1xhiwgbnhrr3yr3ybpfis9slrl73i0b1lc9q89vhip6ym2l"; } # Roblox Player
    { flatpakref = "https://dl.flathub.org/repo/appstream/org.vinegarhq.Vinegar.flatpakref"; sha256="sha256:03l53m3hfwsqr1jbgfs67jr139zsp27nik253b8xgv3s5g59djc0"; } # Roblox Studio
    # { flatpakref = "https://dl.flathub.org/repo/appstream/org.godotengine.GodotSharp.flatpakref"; sha256="sha256:0i58wijbx20kmqz20mwip25qm7nyb8r0azx9nqzbsr3068jb97vq"; } # Godot Mono
  ];
}
