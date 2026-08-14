# Ghostty terminal. The theme is generated from Stylix's active base16 palette
# (`config.lib.stylix.colors`), so it follows whatever theme is selected in
# modules/themes automatically; falls back to Catppuccin Mocha values if
# Stylix isn't present.
{ den, inputs, ... }:
{
  den.aspects.ghostty.homeManager =
    { pkgs, config, ... }:
    let
      s = config.lib.stylix.colors or { };
      c = name: default: s.${name} or default;
    in
    {
      programs.ghostty = {
        enable = true;
        package = pkgs.ghostty;
        settings = {
          font-size = 10;
          theme = "stylix";
          window-padding-x = 14;
          window-padding-y = 16;
          window-height = 28;
          window-width = 90;
          window-padding-balance = true;
          window-padding-color = "background";
        };
        themes = {
          stylix = {
            background = c "base00" "1e1e2e";
            foreground = c "base05" "cdd6f4";
            cursor-color = c "base06" "f5e0dc";
            selection-background = c "base06" "f5e0dc";
            selection-foreground = c "base00" "1e1e2e";
            palette = let
              mk = i: name: default: "${toString i}=#${c name default}";
            in [
              (mk 0 "base08" "f38ba8")
              (mk 1 "base09" "fab387")
              (mk 2 "base0A" "f9e2af")
              (mk 3 "base0B" "a6e3a1")
              (mk 4 "base0C" "94e2d5")
              (mk 5 "base0D" "89b4fa")
              (mk 6 "base0E" "cba6f7")
              (mk 7 "base0F" "f2cdcd")
              (mk 8 "base08" "f38ba8")
              (mk 9 "base09" "fab387")
              (mk 10 "base0A" "f9e2af")
              (mk 11 "base0B" "a6e3a1")
              (mk 12 "base0C" "94e2d5")
              (mk 13 "base0D" "89b4fa")
              (mk 14 "base0E" "cba6f7")
              (mk 15 "base0F" "f2cdcd")
            ];
          };
        };
      };
    };
}
