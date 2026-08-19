{ den, ... }:
{
  den.aspects.audio.nixos = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true; # 32-bit ALSA for Steam/Wine games
      pulse.enable = true;      # PulseAudio emulation for legacy apps

      wireplumber.extraConfig."10-device-priorities" = {
        "monitor.bluez.rules" = [
          {
            # OpenRun Pro 2
            matches = [ { "node.description" = "~*OpenRun*"; } ];
            actions = {
              update-props = {
                "priority.session" = 2000;
                "priority.driver" = 2000;
              };
            };
          }
        ];
        "monitor.alsa.rules" = [
          {
            # HyperX QuadCast
            matches = [ { "node.description" = "~*HyperX*"; } ];
            actions = {
              update-props = {
                "priority.session" = 2500;
                "priority.driver" = 2500;
              };
            };
          }
        ];
      };
    };
  };
}