{ den, ... }:
{
  den.aspects.tailscale.nixos =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.tailscale = {
        enable = true;
        extraSetFlags = [ "--operator=aul" ];
      };
      networking.nftables.enable = true;
      networking.firewall = {
        trustedInterfaces = [
          config.services.tailscale.interfaceName
        ];

        allowedUDPPorts = [
          config.services.tailscale.port
        ];
      };

      systemd.services.tailscaled.serviceConfig.Environment = [ 
        "TS_DEBUG_FIREWALL_MODE=nftables" 
      ];

      systemd.network.wait-online.enable = false; 
      boot.initrd.systemd.network.wait-online.enable = false;
    };
}