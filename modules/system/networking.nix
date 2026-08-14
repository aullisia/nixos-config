{ den, ... }:
{
  den.aspects.networking.nixos = {
    networking = {
      enableIPv6 = true;
      firewall.enable = true;
      networkmanager.enable = true;
    };

    systemd.network.wait-online.enable = false;
  };
}