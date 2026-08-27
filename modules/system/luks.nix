{ den, ... }:
{
  den.aspects.luks.nixos =
    { lib, ... }:
    {
      boot.initrd.systemd.enable = lib.mkDefault true;
      boot.initrd.availableKernelModules = [
        "aesni_intel"
        "cryptd"
        "tpm_crb"
        "tpm_tis"
      ];
    };
}
