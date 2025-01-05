{ config, pkgs, dotFilesPath, modulesPath, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "aul";
  home.homeDirectory = "/home/aul";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.

  home.stateVersion = "24.11"; # Please read the comment before changing.

  imports = [
    (import ./${modulesPath}/programs/firefox { 
      wallpaper = ./${dotFilesPath}/wallpapers/ying-yi-72px.jpg;
      user_js = ./${dotFilesPath}/firefox_user.js;
    } )
    ./${modulesPath}/shell/starship.nix
    (import ./${modulesPath}/programs/alacritty { alacrittyConfigFile = ./${dotFilesPath}/alacritty.toml; } )
  ];

  # Wayfire dotfiles
  # home.file.".config/wayfire.ini" = {
  #   source = ./${dotFilesPath}/wayfire.ini;
  # };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/test/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages

  # Flatpak
  services.flatpak.enable = true;
  services.flatpak.packages = [
    { flatpakref = "https://sober.vinegarhq.org/sober.flatpakref"; sha256="sha256:1pj8y1xhiwgbnhrr3yr3ybpfis9slrl73i0b1lc9q89vhip6ym2l"; } # Roblox Player
  ];

  # Nix
  home.packages = with pkgs; [ 
    fastfetch
    discord
    gimp
    prismlauncher # Minecraft
    # cava # TODO config use xava instead
    eww # TODO config
  ];

  # Overlays
  nixpkgs.overlays = [
    (self: super: {
      discord = super.discord.overrideAttrs (
        _: { src = builtins.fetchTarball {
          url = "https://discord.com/api/download?platform=linux&format=tar.gz";
          sha256 = "sha256:1ivcw1cdxgms7dnqy46zhvg6ajykrjg2nkg91pibv60s5zqjqnj2";
        }; }
      );
    })
  ];
}
