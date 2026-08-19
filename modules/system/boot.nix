{ den, ... }:
{
  den.aspects.boot.nixos =
    { pkgs, host, ... }:
    {
      boot = {
        plymouth.enable = true;
        loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };
          timeout = 3;
          limine = {
            enable = true;
            maxGenerations = 10;

            # Secure Boot setup:
            #   sudo sbctl create-keys
            #   sudo sbctl enroll-keys --microsoft --firmware-builtin
            #   rebuild nixos system
            #   Enable Secure Boot in UEFI, then verify with `sudo sbctl status`.
            secureBoot.enable = builtins.elem host.name [
              "b660"
            ]; # check: nix eval .#nixosConfigurations.b660.config.boot.loader.limine.secureBoot.enable
          };
        };
      };

      environment.systemPackages = [ pkgs.sbctl ];
    };
}