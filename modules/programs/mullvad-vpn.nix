{ den, ... }:
{
  den.aspects.mullvad-vpn.nixos = {
    services.mullvad-vpn = {
      enable = true;
      gui.enable = true;
    };
  };
}