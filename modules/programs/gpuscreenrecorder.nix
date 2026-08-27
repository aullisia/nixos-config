{ den, inputs, ... }:
{
  den.aspects.gpuscreenrecorder = {
    nixos =
      { pkgs, ... }:
      {
        programs.gpu-screen-recorder.enable = true;

        environment.systemPackages = with pkgs; [
          gpu-screen-recorder
          # gpu-screen-recorder-gtk
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          gpu-screen-recorder
        ];
      };
  };
}