{ config, pkgs, inputs, ... }:

{
  xdg.portal = {
    enable = true;
    config = {
      #common.default = "*";
      common = {
        default = ["wlr" "gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
      };
    };
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr

      # Niri
      xdg-desktop-portal-gnome
    ];
  };
}