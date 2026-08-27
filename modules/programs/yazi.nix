{ den, inputs, ... }:
{
  den.aspects.yazi.homeManager =
    { pkgs, config, ... }:
    let
      yaziPlugins = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "c591a36e7263e95497715d525e9c46c2f0a880ac";
        hash = "sha256-mWT0yF2iG9+gYEuNiffpM93POlBqY+QKdFh5jSAxYls=";
      };
    in
    {
      home.sessionVariables = {
        EDITOR = "hx";
        VISUAL = "hx";
      };

      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;

        plugins = {
          smart-enter = "${yaziPlugins}/smart-enter.yazi";
        };

        keymap = {
          mgr.prepend_keymap = [
            {
              on = "l";
              run = "plugin smart-enter";
              desc = "Enter the child directory, or open the file";
            }
          ];
        };

        settings = {
          manager = {
            show_hidden = true;
            sort_by = "alphabetical";
          };

          opener = {
            edit = [
              {
                run = ''hx %s'';
                block = true;
                for = "unix";
              }
            ];

            image = [
              {
                run = ''qimgv %s'';
                orphan = true;
                for = "unix";
              }
            ];

            video = [
              {
                run = ''vlc %s'';
                orphan = true;
                for = "unix";
              }
            ];

            audio = [
              {
                run = ''vlc %s'';
                orphan = true;
                for = "unix";
              }
            ];

            pdf = [
              {
                run = ''brave %s'';
                orphan = true;
                for = "unix";
              }
            ];

            office = [
              {
                run = ''libreoffice %s'';
                orphan = true;
                for = "unix";
              }
            ];
          };

          open = {
            rules = [
              # Text
              { mime = "text/*"; use = "edit"; }
              { url = "*.nix"; use = "edit"; }
              { url = "*.json"; use = "edit"; }
              { url = "*.toml"; use = "edit"; }
              { url = "*.yaml"; use = "edit"; }
              { url = "*.yml"; use = "edit"; }

              # Images
              { mime = "image/png"; use = "image"; }
              { mime = "image/jpeg"; use = "image"; }
              { mime = "image/gif"; use = "image"; }
              { mime = "image/webp"; use = "image"; }
              { mime = "image/bmp"; use = "image"; }
              { mime = "image/tiff"; use = "image"; }
              { mime = "image/svg+xml"; use = "image"; }

              # Video
              { mime = "video/*"; use = "video"; }

              # Audio
              { mime = "audio/*"; use = "audio"; }

              # PDF
              { mime = "application/pdf"; use = "pdf"; }

              # LibreOffice
              { url = "*.docx"; use = "office"; }
              { url = "*.doc"; use = "office"; }
              { url = "*.odt"; use = "office"; }
              { url = "*.xlsx"; use = "office"; }
              { url = "*.xls"; use = "office"; }
              { url = "*.ods"; use = "office"; }
              { url = "*.pptx"; use = "office"; }
              { url = "*.ppt"; use = "office"; }
              { url = "*.odp"; use = "office"; }
            ];
          };
        };
      };
    };
}