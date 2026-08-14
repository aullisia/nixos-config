{ den, inputs, ... }:
{
  den.aspects.fastfetch.homeManager =
    { pkgs, config, ... }:
    let
      esc = builtins.fromJSON ''"\u001b"'';
    in
    {
      programs.fastfetch = {
        enable = true;

        settings = {
          "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

          logo = {
            source = "${inputs.self}/assets/icons/nix-lavender.png";
            type = "kitty";
            height = 14;
            width = 30;

            padding = {
              top = 3;
              left = 3;
            };
          };

          modules = [
            "break"
            "break"

            {
              type = "title";
              key = "󾭹 PC";
              keyColor = "green";
            }

            {
              type = "cpu";
              key = " CPU";
              showPeCoreCount = true;
              format = "{1}";
              keyColor = "green";
            }

            {
              type = "gpu";
              key = " GPU";
              keyColor = "green";
            }

            {
              type = "memory";
              key = " Memory";
              keyColor = "green";
            }

            "break"

            {
              type = "os";
              key = "󾴅 OS";
              keyColor = "yellow";
            }

            {
              type = "kernel";
              key = " Kernel";
              keyColor = "yellow";
            }

            {
              type = "packages";
              key = "󰏖 Packages";
              keyColor = "yellow";
            }

            {
              type = "shell";
              key = " Shell";
              keyColor = "yellow";
            }

            {
              type = "command";
              key = " OS Age";
              keyColor = "yellow";
              text = ''
                birth_install=$(stat -c %W /)
                current=$(date +%s)
                time_progression=$((current - birth_install))
                days_difference=$((time_progression / 86400))
                echo $days_difference days
              '';
            }

            {
              type = "uptime";
              key = " Uptime";
              keyColor = "yellow";
            }

            "break"

            {
              type = "de";
              key = " DE";
              keyColor = "red";
            }

            {
              type = "lm";
              key = " LM";
              keyColor = "red";
            }

            {
              type = "wm";
              key = " WM";
              keyColor = "red";
            }

            {
              type = "gpu";
              key = " GPU Driver";
              format = "{3}";
              keyColor = "red";
            }

            {
              type = "custom";
              format =
                "${esc}[90m  "
                + "${esc}[31m  "
                + "${esc}[32m  "
                + "${esc}[33m  "
                + "${esc}[34m  "
                + "${esc}[35m  "
                + "${esc}[36m  "
                + "${esc}[37m  "
                + "${esc}[0m";
            }

            "break"
          ];
        };
      };
    };
}