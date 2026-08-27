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
        
        extraPackages = with pkgs; [
          nixd
          nixfmt
        ];

        settings = {
          theme = appTheme.theme or "catppuccin_mocha-theme";
          
          editor = {
            line-number = "relative";
            mouse = true;
            bufferline = "multiple";
            cursorline = true;

            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };

            indent-guides = {
              render = true;
              character = "│";
            };
            
            lsp = {
              display-messages = true;
              display-inlay-hints = true;
            };
          };
        };

        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter = {
                command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
              };
              language-servers = [ "nixd" ];
            }
          ];
        };

        themes = {
          catppuccin_mocha-theme = {
            "inherits" = "catppuccin_mocha";
            "ui.background" = { };
          };
        };
      };
    };
}