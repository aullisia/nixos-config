{ config, pkgs, inputs, ... }:

{
  environment.variables = {
    QT_QPA_PLATFORM = "wayland";
    XCURSOR_THEME = "WhiteSur-cursors";
    XCURSOR_SIZE = "20";
  };
}