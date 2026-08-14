{ den, ... }:
{
  den.aspects.nixsettings.nixos =
    { lib, ... }:
    {
      nixpkgs = {
        config = {
          allowUnfree = true;
        };
      };
      nix = {
        gc = {
          automatic = lib.mkDefault true;
          dates = lib.mkDefault "daily";
          options = lib.mkDefault "--delete-older-than 5d";
        };
        settings = {
          # enable flakes
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          substituters = [
            "https://cache.nixos.org"
          ];
          trusted-substituters = [
            # Official nix cache
            "https://cache.nixos.org"
          ];
          trusted-public-keys = [
            # Official nix cache
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
          allowed-users = [
            "root"
            "@wheel"
          ];
          connect-timeout = 10;
          stalled-download-timeout = 100;
          download-attempts = 5;
        };
      };

      # Log rebuild
      system.activationScripts.logRebuildTime = {
        text = ''
          LOG_FILE="/var/log/nixos-rebuild-log.json"
          TIMESTAMP=$(date "+%d/%m")
          GENERATION=$(readlink /nix/var/nix/profiles/system | grep -o '[0-9]\+')

          echo "{\"last_rebuild\": \"$TIMESTAMP\", \"generation\": $GENERATION}" > "$LOG_FILE"
          chmod 644 "$LOG_FILE"
        '';
      };
    };
}