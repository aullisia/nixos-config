{ config, pkgs, home-manager, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
    (import ../../modules/desktops/gnome.nix)
    (import ../../modules/desktops/wayfire.nix { wayfireConfig =  ../../dotfiles/wayfire.ini; } )
  ];

  # Services for Gnome
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

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

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # System Packages
  services.flatpak.enable = true;
  services.flatpak.packages = [
    { flatpakref = "https://dl.flathub.org/repo/appstream/org.vinegarhq.Sober.flatpakref"; sha256="sha256:15ak2i5nk64wbmswqml2cqfgidczawqybmc7pmw94yp8wcd4yv6i"; } # Roblox Player
    { flatpakref = "https://dl.flathub.org/repo/appstream/org.vinegarhq.Vinegar.flatpakref"; sha256="sha256:03l53m3hfwsqr1jbgfs67jr139zsp27nik253b8xgv3s5g59djc0"; } # Roblox Studio
  ];
  environment.systemPackages = with pkgs; [

  ];
}
