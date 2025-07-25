{ config, pkgs, lib, home-manager, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  imports =
  [
    ./hardware-configuration.nix
    (import ../../modules/desktops/kde.nix { 
      wallpaper =  ../../dotfiles/wallpapers/wallhaven-x6vjkz_1920x1080.png;
    })
    (import ../../modules/desktops/niri { 
      wallpaper =  ../../dotfiles/wallpapers/frier.png;
    })
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.blueman.enable = true; # Bluetooth GUI
  # TODO: From blueman-manager, go in View->Plugins and uncheck "StatusIcon" do this declaratively

  # SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
  };

  # GPU
  environment.variables.VDPAU_DRIVER = "va_gl";
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      pkgs.driversi686Linux.mesa
      libvdpau-va-gl
    ];
  };

  environment.variables.AMD_VULKAN_ICD = lib.mkDefault "RADV";
  hardware.enableRedistributableFirmware = true;

  hardware.enableAllFirmware = true;
  boot.kernelParams = [ "amdgpu.dc=1" ];

  # Firewall
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

  environment.sessionVariables = rec {
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"; # Allow godot mono to work
  };

  # Ollama
  services.ollama = {
    enable = true;
    # loadModels = [ "deepseek-r1:7b" ];
    acceleration = "rocm";
    # environmentVariables = {
    #   HCC_AMDGPU_TARGET = "gfx1031";
    # };
    # rocmOverrideGfx = "10.3.0";
  };
  
  services.open-webui = {
    enable = true;
    port = 24460;
  };

  # Controller
  hardware.steam-hardware.enable = true; 
  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # OpenRGB
  services.hardware.openrgb = { 
    enable = true; 
    package = pkgs.openrgb-with-all-plugins; 
    server = { 
      port = 6742; 
    }; 
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
    { appId = "org.vinegarhq.Sober"; origin = "flathub";  }
    { appId = "org.vinegarhq.Vinegar"; origin = "flathub";  }
  ];

  # environment.variables.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "true";

  environment.systemPackages = with pkgs; [
    # gwe # GreenWithEnvy
    # tuxclocker
    unigine-superposition
    efibootmgr
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
    protontricks
    catppuccin-kde
    kdePackages.qtmultimedia
    jdk21
    jdk17
    dotnet-sdk_9
    protonup-qt
    sddm-astronaut
    catppuccin-grub
    linuxKernel.packages.linux_6_15.xone linuxKernel.packages.linux_6_15.xpadneo # Controller

    # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
    (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
      pkgs.buildFHSEnv (base // {
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

  # nixpkgs.overlays = [
  #   (self: super: {
  #     ollama = super.ollama.overrideAttrs (old: {
  #       cmakeFlags = (old.cmakeFlags or []) ++ [
  #         "-DCMAKE_CUDA_ARCHITECTURES=86"
  #       ];
  #     });
  #   })
  # ];
}
