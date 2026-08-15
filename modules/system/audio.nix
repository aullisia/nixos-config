{ den, ... }:
{
  den.aspects.audio.nixos = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true; # 32-bit ALSA for Steam/Wine games
      pulse.enable = true;      # PulseAudio emulation for legacy apps
    };
  };
}