{ config, pkgs, unstable, dotFilesPath, modulesPath, lib, vars, spicetify-nix, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${vars.user}";
  home.homeDirectory = "/home/${vars.user}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.

  home.stateVersion = "25.05"; # Please read the comment before changing.

  imports = [
    (import ./${modulesPath}/programs/firefox { 
      wallpaper = ./${dotFilesPath}/wallpapers/wallpaper-theme-converter3.png;
    } )
   ./${modulesPath}/shell/starship.nix
   ./${modulesPath}/programs/ghostty.nix
    (import ./${modulesPath}/programs/alacritty { alacrittyConfigFile = ./${dotFilesPath}/alacritty.toml; } )
  ];

  home.sessionVariables = {
    # EDITOR = "emacs";
    # DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Fastfetch
  home.file.".config/fastfetch" = {
    source = ./${dotFilesPath}/fastfetch/catppuccin;
  };

  # OpenRGB autostart
  home.file."bin/openrgb-load-profile" = {
    executable = true;
    text = 
    ''
      #!/run/current-system/sw/bin/bash
      PROFILE="$HOME/.config/OpenRGB/prpl.orp"
      MAX_RETRIES=10
      RETRY_DELAY=1
      PORT=6742

      if [[ ! -f "$PROFILE" ]]; then
        echo "OpenRGB profile not found at $PROFILE"
        exit 1
      fi

      echo "Waiting for OpenRGB server on port $PORT..."

      for ((i=1; i<=MAX_RETRIES; i++)); do
        if command -v nc >/dev/null 2>&1; then
          if nc -z localhost "$PORT"; then
            echo "OpenRGB server is ready."
            break
          fi
        else
          timeout 1 bash -c "echo > /dev/tcp/localhost/$PORT" 2>/dev/null && {
            echo "OpenRGB server is ready."
            break
          }
        fi

        echo "Attempt $i: OpenRGB not ready, retrying in $RETRY_DELAY second(s)..."
        sleep "$RETRY_DELAY"

        if [[ $i -eq $MAX_RETRIES ]]; then
          echo "OpenRGB server not responding on port $PORT after $MAX_RETRIES attempts."
          exit 1
        fi
      done

      echo "Loading OpenRGB profile: $PROFILE"
      openrgb --profile "$PROFILE" && echo "Profile loaded successfully." || {
        echo "Failed to load profile."
        exit 1
      }
    '';
  };

  # Packages

  # Flatpak
  # services.flatpak.enable = true;
  # services.flatpak.packages = [
  #   { flatpakref = "https://sober.vinegarhq.org/sober.flatpakref"; sha256="sha256:1pj8y1xhiwgbnhrr3yr3ybpfis9slrl73i0b1lc9q89vhip6ym2l"; } # Roblox Player
  # ];

  # Spicetify
  programs.spicetify =
  let
    spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
    enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "CatppuccinMacchiato";
  };

  # Nix
  home.packages = with pkgs; [ 
    fastfetch
    vscode
    nb # notes
    trilium-desktop
    qimgv
    vesktop # discord
    # webcord-vencord
    unstable.brave
    vlc
    # unstable.spotify
    prismlauncher
    ckan
    flameshot
    #satty
    p7zip
    jetbrains-toolbox
    jetbrains.idea-ultimate
    jetbrains.rider
    gimp
    obs-studio
    blender
    blockbench
    shotcut
    xpipe
    gamescope
    ani-cli
    # unstable.godot_4_4-mono
    unstable.godot_4_4
    figma-linux
    chntpw
    unstable.steam-devices-udev-rules
    qdirstat
    webcord-vencord
    # unstable.cowsay
    switcheroo
    resources
    devtoolbox
    clapgrep
    usbimager
    grim slurp swappy
    # kdePackages.spectacle
    # gowall
  ];

  # Overlays
  # nixpkgs.overlays = [];
}
