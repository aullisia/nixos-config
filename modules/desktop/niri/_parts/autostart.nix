{
  config,
  pkgs,
  autoReplayScript,
  ...
}: {
  programs.niri.settings.spawn-at-startup = [
    { command = [ "polkit-kde-authentication-agent-1" ]; }
    { command = [ "xwayland-satellite" ]; }
    { command = [ "noctalia" ]; }
    { command = [ "skwd-daemon" ]; }
    { command = ["vesktop"]; }
    { command = ["spotify"]; }
    { command = [ "tailscale" "systray" ]; }
  ];
}
