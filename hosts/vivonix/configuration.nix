{ config, inputs, self, vars, pkgs, lib, ... }:

let
  packages = import ./system-packages.nix { inherit pkgs;};
in
{
  imports =
  [
    ./hardware-configuration.nix

    "${self}/modules/greeters/greetd.nix"
    "${self}/modules/desktops/niri"
    "${self}/modules/programs/stylix.nix"
    "${self}/modules/programs/quickshell"
    "${self}/modules/programs/plymouth.nix"
    "${self}/modules/services/xdg.nix"
    "${self}/modules/services/environment.nix"
  ];

  networking.hostName = lib.mkForce "vivonix";

  # Power
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # USB
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  users.users."${vars.user}".extraGroups = [ "storage" ];

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.blueman.enable = true; # Bluetooth GUI
  # TODO: From blueman-manager, go in View->Plugins and uncheck "StatusIcon" do this declaratively
  
  # Secrets
  services.gnome.gnome-keyring.enable = true;

  # Graphics Drivers
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      mesa
    ];
  };

  # ENV
  environment.sessionVariables = rec {
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
  };

  # Shell aliases
  programs.bash.shellAliases = {
    ff = "fastfetch";
  };

  # Wireguard VPN
  networking.wg-quick.interfaces = {
    wg0 = {
      configFile = "/etc/wireguard/wg0.conf";
      autostart = false;
    };
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];

  # direnv
  programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    silent = false;
    loadInNixShell = true;
    direnvrcExtra = "";
    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
  };

  # Flatpak
  services.flatpak.enable = true;

  # System Packages
  environment.systemPackages = packages;
}