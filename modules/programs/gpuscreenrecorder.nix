{ den, inputs, ... }:
{
  den.aspects.gpuscreenrecorder.nixos =
    { pkgs, config, ... }:
    {
      programs.gpu-screen-recorder.enable = true;
      environment.systemPackages = with pkgs; [
        gpu-screen-recorder-gtk # GUI app
      ];
    };
}