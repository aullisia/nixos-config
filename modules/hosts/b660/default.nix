{ den, inputs, ... }:
{
  den.aspects.b660 = {
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
    ];

    nixos =
      { lib, pkgs, ... }:
      {
        imports = [ (inputs.self + "/hosts/b660/hardware-configuration.nix") ];

        hardware.cpu.intel.updateMicrocode = true;
        boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            libva-vdpau-driver
            libvdpau-va-gl
          ];
          extraPackages32 = with pkgs.pkgsi686Linux; [
            libvdpau-va-gl
          ];
        };
        environment.variables = {
          AMD_VULKAN_ICD = "RADV";
          VDPAU_DRIVER = "va_gl";
        };
        boot.initrd.kernelModules = [ "amdgpu" ];
        hardware.enableRedistributableFirmware = true;

        services.ollama = {
          enable = true;
          package = pkgs.ollama-rocm;
          # If ROCm fails to detect the 9060 XT (gfx1200), uncomment:
          # rocmOverrideGfx = "12.0.0";
        };

        services.power-profiles-daemon.enable = true;

        networking.firewall = {
          allowedTCPPorts = [ 25565 24454 24460 ];
          allowedUDPPorts = [ 25565 24454 ];
        };

        boot.loader.limine.extraEntries = ''
          /Windows
            protocol: efi
            path: guid(8092b2db-9158-4499-a6ac-003a21fbba74):/EFI/Microsoft/Boot/bootmgfw.efi
        '';
      };
  };
}
