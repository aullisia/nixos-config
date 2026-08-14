{ den, ... }:
{
  den.aspects.ssh = {
    nixos = { ... }: {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };

      # Open firewall for SSH
      networking.firewall.allowedTCPPorts = [ 22 ];
    };
  };
}
