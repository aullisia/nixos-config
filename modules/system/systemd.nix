{ den, ... }:
{
  den.aspects.systemd.nixos = {
    systemd = {
      network.enable = true;
      sleep.settings.Sleep = {
        AllowSuspend = "yes";
        AllowHibernation = "yes";
        SuspendState = "mem";
        SuspendMode = "deep";
      };
      settings = {
        Manager = {
          DefaultTimeoutStopSec = "10s";
        };
      };
    };

    # /var/log is bind-mounted from /persistent; make journald's persistent
    # storage explicit instead of relying on Storage=auto detecting
    # /var/log/journal.
    services.journald.extraConfig = ''
      Storage=persistent
    '';

    # Frequent root snapshotting/deletion can fragment btrfs metadata and hide
    # silent corruption; scrub monthly to detect and repair it.
    #
    # fileSystems is explicit and scoped to "/" only: /, /nix, and /persistent
    # are all mountpoints of the same underlying device, so scrubbing all
    # three (the default when fileSystems is unset) would redo the same
    # physical work three times over for no benefit.
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
}