{
  config,
  pkgs,
  ...
}: {
  programs.niri.settings.spawn-at-startup = [
    { command = [ "xwayland-satellite" ]; }
    { command = [ "noctalia" ]; }
    { command = [ "skwd-daemon" ]; }
  ];
}
