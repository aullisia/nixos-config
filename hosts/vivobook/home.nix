{ config, pkgs, dotFilesPath, modulesPath, lib, vars, ... }:

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

  home.stateVersion = "24.11"; # Please read the comment before changing.

  imports = [
    (import ./${modulesPath}/programs/firefox { 
      wallpaper = ./${dotFilesPath}/wallpapers/ying-yi-72px.jpg;
      user_js = ./${dotFilesPath}/firefox_user.js;
    } )
   ./${modulesPath}/shell/starship.nix
    (import ./${modulesPath}/programs/alacritty { alacrittyConfigFile = ./${dotFilesPath}/alacritty.toml; } )
  ];

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages

  # Flatpak
  services.flatpak.enable = true;
  services.flatpak.packages = [];

  # Nix
  home.packages = with pkgs; [ 
    fastfetch
    prismlauncher # Minecraft
    jetbrains-toolbox
    jetbrains.idea-ultimate
    jetbrains.rider
    vscode
  ];

  # Overlays
  nixpkgs.overlays = [];
}
