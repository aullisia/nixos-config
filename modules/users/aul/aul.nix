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