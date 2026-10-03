{ den, ... }:
{
  den.aspects.virt-manager =
    { host, user, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          programs.virt-manager.enable = true;

          virtualisation = {
            libvirtd.enable = true;
            spiceUSBRedirection.enable = true;
          };

          environment.systemPackages = [
            pkgs.qemu
          ];

          # Add user to the libvirtd group
          users.users.${user.userName}.extraGroups = [ "libvirtd" ];
        };

      homeManager =
        { pkgs, ... }:
        {
          dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = [ "qemu:///system" ];
              uris = [ "qemu:///system" ];
            };
          };
        };
    };
}
