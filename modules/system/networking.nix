{ den, ... }:
{
  den.aspects.networking.nixos = {
    networking = {
      nftables.enable = true;
      enableIPv6 = true;
      firewall = {
        enable = true;
        # allowedTCPPortRanges = [
        #   { from = 1714; to = 1764; }
        # ];
        # allowedUDPPortRanges = [
        #   { from = 1714; to = 1764; }
        # ];
      };
      networkmanager.enable = true;
    };

    systemd.network.wait-online.enable = false;
  };
}