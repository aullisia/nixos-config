{ den, inputs, ... }:
{
  den.aspects.helix.homeManager =
    { pkgs, config, ... }:
    let
      appTheme = ((config.modules.theme or { }).apps or { }).helix or { };
    in
    {
      programs.helix = {
        enable = true;
        settings = {
          theme = appTheme.theme or "catppuccin_mocha-theme";
          editor.cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
        };
        languages.language = [{
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }];
        themes = {
          catppuccin_mocha-theme = {
            "inherits" = "catppuccin_mocha";
            # "ui.background" = { };
          };
        };
      };
    };
}