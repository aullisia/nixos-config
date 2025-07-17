{ config, pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      font-size = 10;
      theme = "catppuccin-mocha";
      window-padding-x = 14;
      window-padding-y = 16;
      window-height = 28;
      window-width = 90;
      window-padding-balance = true;
      window-padding-color = "background"; 
    };
    themes = {
      catppuccin-mocha = {
        background = "1e1e2e";
        foreground = "cdd6f4";
        cursor-color = "f5e0dc";
        selection-background = "f5e0dc";
        selection-foreground = "1e1e2e";
        palette = [
          "0=#45475a"
          "1=#f38ba8"
          "2=#a6e3a1"
          "3=#f9e2af"
          "4=#89b4fa"
          "5=#f5c2e7"
          "6=#94e2d5"
          "7=#bac2de"
          "8=#585b70"
          "9=#f38ba8"
          "10=#a6e3a1"
          "11=#f9e2af"
          "12=#89b4fa"
          "13=#f5c2e7"
          "14=#94e2d5"
          "15=#a6adc8"
        ];
      };
    };
  };
}
