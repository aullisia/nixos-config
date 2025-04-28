{ config, pkgs, home-manager, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
    (import ../../modules/desktops/wayfire.nix { 
      wayfireConfig =  ../../dotfiles/wayfire.ini;
      wfShell = ../../dotfiles/wf-shell.ini;
      wfDock = ../../dotfiles/wf-dock.css;
      ironbarConfig = ../../dotfiles/ironbar;
      ulauncherConfig = ../../dotfiles/ulauncher;
      wfPanel = ../../dotfiles/wf-panel.css;
    })
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

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true; # Bluetooth GUI

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 25565 24454 ];
    allowedUDPPorts = [ 24454 25565 ];
  };

  # Shell aliases
  programs.bash.shellAliases = {
    nixb = "sudo nixos-rebuild switch --flake .#b660";
    ff = "fastfetch";
  };

  # Steam
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
  services.flatpak.enable = true;
  services.flatpak.packages = [
    # { flatpakref = "https://dl.flathub.org/repo/appstream/org.vinegarhq.Sober.flatpakref"; sha256="0000000000000000000000000000000000000000000000000000"; } # Roblox Player
    { appId = "org.vinegarhq.Sober"; origin = "flathub";  }
    { flatpakref = "https://dl.flathub.org/repo/appstream/org.vinegarhq.Vinegar.flatpakref"; sha256="sha256:03l53m3hfwsqr1jbgfs67jr139zsp27nik253b8xgv3s5g59djc0"; } # Roblox Studio
  ];

  # environment.variables.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "true";

  environment.systemPackages = with pkgs; [
    # gwe # GreenWithEnvy
    # tuxclocker
    # unigine-superposition
    winetricks
    protontricks
    catppuccin-kde
    kdePackages.qtmultimedia
    jdk21_headless
    jdk17_headless
    dotnet-sdk_9

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
}
