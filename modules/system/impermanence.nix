# Full desktop impermanence (btrfs).
#
# Pairs with the installer's disk layout (installer/01-format.sh):
#
#   Btrfs
#   ├── @            -> /            (wiped back to @blank every boot)
#   ├── @nix         -> /nix         (persistent)
#   ├── @persistent  -> /persistent  (persistent; bind-mounted back into /
#   │                                  by nix-community/impermanence)
#   └── @blank       (not mounted; pristine empty snapshot, template for @)
#
# NOTE: unlike an earlier version of this module, /home is deliberately NOT
# its own subvolume. It's just an ordinary directory inside the wiped @
# subvolume, like everything else under /. A separate wipe-and-rollback
# mechanism for /home was tried and caused a string of real bugs (subvolume
# ID confusion, unit-ordering races, /etc/shadow bind-mount conflicts) for
# no actual benefit over this simpler approach: one wipe mechanism for
# everything under /, and environment.persistence."/persistent".users.<name>
# (below) bind-mounts back exactly what should survive under $HOME. This
# design mirrors a known-working reference config rather than inventing a
# second parallel rollback path.
#
# On every boot, a systemd-in-initrd oneshot service deletes the current @
# and replaces it with a fresh snapshot of @blank, so anything written
# directly to / (including $HOME, since it's just a directory under /) is
# gone on reboot. environment.persistence."/persistent" (system-wide) and
# its nested `.users.<name>` (per-user, home-relative paths) then bind-mount
# back exactly what should survive.
#
# This installation uses systemd in stage 1 (initrd), which does NOT support
# boot.initrd.postDeviceCommands — the rollback has to be a proper
# boot.initrd.systemd.services unit instead.
#
# NOTE: /etc/shadow deliberately does NOT appear in the files list below.
# Bind-mounting it doesn't work — NixOS's user-activation script replaces
# /etc/shadow via write-temp-then-rename on every rebuild, which fails
# against a bind-mounted file ("Device or resource busy"). Account
# passwords are handled declaratively instead, via hashedPasswordFile in
# modules/users/aul/aul.nix — see the comment there. SSH host keys, by
# contrast, ARE safe to bind-mount directly (below) — nothing rewrites them
# in place once they exist; sshd's keygen unit only generates them if
# missing.
#
# Keep the `directories`/`files` lists here in sync with what the installer
# seeds in installer/02-configure.sh.
{ den, inputs, ... }:
{
  den.aspects.impermanence.nixos =
    { config, lib, ... }:
    {
      imports = [ inputs.impermanence.nixosModules.impermanence ];

      boot.initrd.systemd.enable = true;
      boot.initrd.supportedFilesystems = [ "btrfs" ];

      # environment.persistence's per-user bind mounts are done as root but
      # need to be usable by the owning user — this is what makes that work.
      programs.fuse.userAllowOther = true;

      # /persistent and /nix have to be mounted (and thus their data
      # available) before the rest of boot proceeds, since
      # environment.persistence bind-mounts out of /persistent very early
      # (e.g. for /etc/machine-id, SSH host keys), and /nix backs the store
      # everything else depends on.
      fileSystems."/persistent".neededForBoot = true;
      fileSystems."/nix".neededForBoot = true;

      # Roll @ back to the blank snapshot on every boot. Old roots are kept
      # for 30 days under /old_roots for forensics/rescue, then
      # garbage-collected.
      boot.initrd.systemd.services.rollback-root = {
        description = "Roll back the root subvolume to a pristine state";
        wantedBy = [ "initrd.target" ];
        after = [ "initrd-root-device.target" ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /btrfs_tmp
          mount -t btrfs -o subvol=/ "${config.fileSystems."/".device}" /btrfs_tmp

          # @blank is the single point of failure: if it is missing or
          # corrupt we must NOT delete the current @ — boot it as-is so the
          # system still comes up for rescue instead of failing to mount root.
          if [ ! -e /btrfs_tmp/@blank ]; then
            echo "CRITICAL: @blank snapshot missing! Booting current @ to allow rescue."
            umount /btrfs_tmp
            exit 0
          fi

          if [ -e /btrfs_tmp/@ ]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%d_%H:%M:%S")
            mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/@-$timestamp"
          fi

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -name "@-*" -mtime +30 2>/dev/null); do
            delete_subvolume_recursively "$i"
          done

          btrfs subvolume snapshot /btrfs_tmp/@blank /btrfs_tmp/@
          umount /btrfs_tmp
        '';
      };

      # /var/lib/systemd/random-seed is persisted (see the files list below);
      # ensure the bind/symlink lands BEFORE systemd-random-seed.service runs,
      # or mount-file.bash aborts with "A file already exists at ...".
      # Unit name = persist + escaped path: "/" -> "-", "-" -> "\x2d".
      systemd.services."persist-persistent-var-lib-systemd-random\\x2dseed" = {
        before = [ "systemd-random-seed.service" ];
      };

      environment.persistence."/persistent" = {
        enable = true;
        hideMounts = true;
        allowTrash = true;

        directories = [
          "/etc/NetworkManager/system-connections"
          "/var/cache/tuigreet" # greetd/tuigreet --remember last-user state
          "/var/lib/bluetooth"
          "/var/lib/docker"
          "/var/lib/flatpak" # system-wide Flatpak repos/runtime (wiped otherwise; .var/app is per-user only)
          "/var/lib/libvirt"
          "/var/lib/nixos"
          "/var/log"
          "/root"
          "/var/db/sudo/lectured" # skip the "you've been lectured" sudo message every boot
        ];

        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/var/lib/systemd/random-seed" # smooths entropy reset across boots
        ];

        # Per-user whitelist for $HOME. This is deliberately a whitelist,
        # not a blocklist — most app config (Plasma, ghostty, helix, git,
        # zsh, ...) is already fully declarative via Home Manager and gets
        # rewritten from the flake on every activation anyway, so it doesn't
        # belong here. What's listed below is either real user data, or
        # state from apps that have no Nix module and would otherwise lose
        # logins/extensions/library data on every reboot.
        users.aul = {
          directories = [
            # Real user data
            "Downloads"
            "Documents"
            "Pictures"
            "Videos"
            "Music"

            # The flake itself
            "nixos-config"

            # Identity / credentials
            ".ssh"
            ".gnupg"
            ".config/gh"

            # Apps with no Nix module
            ".librewolf"
            ".config/vesktop"
            ".config/Code"
            ".vscode"
            ".local/share/JetBrains"
            ".config/JetBrains"
            ".local/share/Steam"
            ".steam"
            ".local/share/PrismLauncher"
            ".var/app"
            ".config/obsidian"
            ".config/zsh"
            ".cache/skwd-wall"
            ".config/skwd-wall"
          ];
        };
      };
    };
}
