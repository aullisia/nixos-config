{ den, inputs, lib, ... }:
{
  den.aspects.auronix = {
    includes = [
      # Core system
      den.aspects.boot
      den.aspects.locale
      den.aspects.networking
      den.aspects.systemd
      den.aspects.users
      den.aspects.overlays
      den.aspects.nixsettings
      den.aspects.audio
      den.aspects.printing

      # Hardware
      den.aspects.kernel
      den.aspects.openrgb

      # Services
      # den.aspects.ssh
      den.aspects.swap
      den.aspects.impermanence
      den.aspects.luks
    ];

    nixos =
      { lib, pkgs, config, ... }:
      {
        imports =
          [
            (inputs.self + "/hosts/auronix/hardware-configuration.nix")
          ]
          ++ lib.optionals (builtins.pathExists (inputs.self + "/hosts/auronix/luks-configuration.nix")) [
            (inputs.self + "/hosts/auronix/luks-configuration.nix")
          ];

        hardware.cpu.amd.updateMicrocode = true;

        boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
        boot.initrd.kernelModules = [ "amdgpu" ];

        hardware.graphics = {
          enable = true;
          enable32Bit = true;

          # extraPackages = with pkgs; [
          #   libva-vdpau-driver
          #   libvdpau-va-gl
          #   nvidia-vaapi-driver
          # ];

          extraPackages32 = with pkgs.pkgsi686Linux; [
            libvdpau-va-gl
          ];
        };

        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
          modesetting.enable = true;

          powerManagement = {
            enable = true;
            finegrained = true;
          };

          # RTX 5060 / Blackwell
          open = true;

          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;

          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };

            # Verify against:
            # lspci -D | grep -E "VGA|3D|Display"
            amdgpuBusId = "PCI:6:0:0";
            nvidiaBusId = "PCI:1:0:0";
          };
        };

        # services.asusd = {
        #   enable = true;
        #   enableUserService = true;
        # };
        # services.supergfxd = {
        #   enable = true;
        # };

        hardware.enableRedistributableFirmware = true;
        services.power-profiles-daemon.enable = true;

        virtualisation.docker.enable = true;
        users.users.aul.extraGroups = [ "docker" ];
      };
  };
}