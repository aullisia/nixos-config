{ den, inputs, ... }:
{
  den.aspects.aul = {
    includes = [
      # -- Desktop --
      # den.aspects.plasma

      den.aspects.niri
      den.aspects.greetd

      # -- System stuff --
      den.aspects.themes
      den.aspects.stylix
      den.aspects.zsh
      den.aspects.lsd
      den.aspects.git
      den.aspects.bat
      den.aspects.fastfetch
      den.aspects.bluetooth
      den.aspects.flatpak
      den.aspects.nh


      # -- Dev --
      den.aspects.godot
      den.aspects.direnv
      den.aspects.helix
      den.aspects.jetbrains

      # -- Apps --
      den.aspects.librewolf
      den.aspects.ghostty
      den.aspects.vesktop
      den.aspects.spicetify
      den.aspects.gpuscreenrecorder

      # -- Gaming --
      den.aspects.steam
      den.aspects.mangohud
    ];

    homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
      # TEMPORARY WORKAROUND for an upstream plasma-manager bug (confirmed
      # still present as of the pinned rev, 2026-08-03): modules/input.nix
      # unconditionally does `builtins.head invalidHexCodes` while building
      # its assertion's `message` string, even when invalidHexCodes is
      # empty — which it always is here, since this config defines no
      # per-device mice/touchpads at all. Home Manager's own per-profile
      # assertion wrapping (nixos/common.nix) forces every assertion's
      # message eagerly, not just failing ones, so this throws
      # "list index 0 is out of bounds" unconditionally, on every build.
      # This is not caused by anything in this flake. Zeroing out this
      # user's HM assertions is blunt (it suppresses other real HM
      # assertion failures too), but unblocks building at all. Retry
      # `nix flake lock --update-input plasma-manager` periodically and
      # remove this once upstream fixes it.
      assertions = lib.mkForce [ ];

      # User packages
      home.packages = with pkgs; [
        # Development
        blender
        vscode
        tree
        inputs.nix-versions.packages.${pkgs.stdenv.hostPlatform.system}.default

        # Image / Media
        qimgv
        vlc
        pinta
        audacity
        lmms

        # Office / Productivity
        hunspell
        hunspellDicts.nl_NL
        libreoffice-qt
        obsidian

        # Gaming
        prismlauncher
      ];

      services.flatpak.packages = [
        "org.vinegarhq.Sober"
        "org.vinegarhq.Vinegar"
        "org.ferdium.Ferdium"
      ];
    };

    nixos =
      { ... }:
      {
        # Passwords are declarative, not interactive `passwd` — this is the
        # One-time setup per hash file (from a root shell, chrooted or not):
        #   mkdir -p /persistent/etc/users
        #   mkpasswd -m sha-512 > /persistent/etc/users/aul.hash
        #   chmod 600 /persistent/etc/users/aul.hash
        # (same for root.hash). `mkpasswd` is in the `mkpasswd` package —
        # `nix run nixpkgs#mkpasswd -- -m sha-512` works from the install ISO.
        users.mutableUsers = false;

        users.users.aul = {
          description = "aul";
          hashedPasswordFile = "/persistent/etc/users/aul.hash";
          extraGroups = [
            "networkmanager"
            "audio"
            "video"
            "input"
            "libvirtd"
            "dialout"
          ];
        };

        users.users.root.hashedPasswordFile = "/persistent/etc/users/root.hash";
      };
  };
}