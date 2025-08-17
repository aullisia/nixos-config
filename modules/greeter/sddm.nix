{
  config,
  pkgs,
  ...
}:

{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];
}