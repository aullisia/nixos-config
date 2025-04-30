{ config, pkgs, home-manager, vars, ... }:

{
  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    nwg-bar
  ];

  home-manager.users."${vars.user}" = {
    home.file.".config/hypr/scripts/waybar-toggle.sh".source = ../../dotfiles/hyprland/scripts/waybar-toggle.sh;
    home.file.".config/waybar/scripts/mic-toggle.sh".source = ../../dotfiles/hyprland/scripts/mic-toggle.sh;
    home.file.".config/waybar/scripts/volume.sh".source = ../../dotfiles/hyprland/scripts/volume.sh;

    programs = {
      rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
      };

      waybar = {
        enable = true;

        style = ''
          * {
            font-family: "FiraCode Nerd Font", sans-serif;
            font-size: 13px;
          }

          #network {
            color: white;
            padding: 0 10px;
          }

          window#waybar {
            transition-property: background-color;
            transition-duration: .5s;
          }

          button {
            /* Use box-shadow instead of border so the text isn't offset */
            box-shadow: inset 0 -3px transparent;
            /* Avoid rounded borders under each button name */
            border: none;
            border-radius: 0;
          }

          /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
          button:hover {
            background: inherit;
            box-shadow: inset 0 -3px #ffffff;
          }

          #workspaces button {
            padding: 0 5px;
            background-color: transparent;
            color: #ffffff;
          }


          #workspaces button:hover {
            background: rgba(0, 0, 0, 0.2);
          }

          #workspaces button.focused {
            background-color: @lavender;
            box-shadow: inset 0 -3px #ffffff;
          }

          #workspaces button.urgent {
            background-color: #eb4d4b;
          }

          #custom-mic-control {
            margin-left: 5px;
          }
        '';

        settings = [
          {
            layer = "top";
            position = "top";
            height = 30;

            # Clock Power network Bluetooth Mute_Mic VPN
            modules-left = [ "clock" "custom/power" "network" "bluetooth" "custom/mic-control" "vpn" ];
            # Workspaces Power_Profiles
            modules-center = [ "hyprland/workspaces" "power-profiles-daemon" ];
            # Battery Volume Brightness
            modules-right = [ "battery" "custom/volume" "custom/brightness" ];

            "clock" = {
              interval = 60;
              format = "[  {:%H:%M} ]";
              tooltip-format = "{:%A, %B %d, %Y | %H:%M:%S}";
            };

            "network" = {
              interface = "enp4s0";
  
              format-wifi = "[ {icon} {essid} ]";
              format-ethernet = "󰈁"; 
              format-disconnected = "󰤭";

              tooltip-format = "Interface: {ifname}\nIP: {ipaddr}\nDownload: {bandwidthDownBits}\nUpload: {bandwidthUpBits}";
              tooltip = true;

              # Dynamic icons based on signal strength
              format-icons = {
                wifi = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
                ethernet = "󰈁";
                disconnected = "󰤭";
              };
            };

            "bluetooth" = {
              format = "[  {status} ]";
              format-on = " On";
              format-off = " Off";

              format-connected = "[  {device_alias} ]";
              format-connected-battery = "[  {device_alias} {device_battery_percentage}% ]";

              tooltip = true;
              tooltip-format = "{controller_alias} ({controller_address})\n\n{num_connections} connected\n\n{device_enumerate}";
              tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";

              on-click = "blueman-manager";
            };

            "custom/power" = {
              format =  "[ ⏻ ]";
              on-click = "nwg-bar";
              tooltip = false;
              class = "powerbtn";
            };

            "custom/mic-control" = {
              exec = "~/.config/waybar/scripts/mic-toggle.sh";
              interval = 1;
              return-type = "json";
              on-click = "~/.config/waybar/scripts/mic-toggle.sh";
              tooltip = false;
              class = "mic-control";
            };


            "vpn" = {
              # vpn commands that correspond to wg-quick https://github.com/HarHarLinks/wireguard-rofi-waybar ??
            };

            "power-profiles-daemon" = {
              format = "[ {icon} {profile} ]";
              tooltip-format = "Power profile: {profile}\nDriver: {driver}";
              tooltip = true;
              format-icons = {
                default = "";
                performance = "";
                balanced = "";
                power-saver = "";
              };
            };

            "hyprland/workspaces" = {
              format = "{icon}";
              on-click = "activate";
              format-icons = {
                active = " ";
              };
              sort-by-number = true;
              persistent-workspaces = {
                "*" = 4; # 4 workspaces by default on every monitor
              };
            };

            "battery" = {
              interval = 60;
              states = {
                  warning = 30;
                  critical = 15;
              };
              format = "{capacity}% {icon}";
              format-icons = ["" "" "" "" ""];
              max-length = 25;
            };

            # "custom/volume" = {
            #   format =  " [█████░░░░░]50%";
            #   tooltip = false;
            # };

            "custom/volume" = {
              exec = "~/.config/waybar/scripts/volume.sh";
              interval = 1;
              return-type = "json";
              on-click = "~/.config/waybar/scripts/volume.sh toggle";
              tooltip = false;
              class = "volume";
            };


            "custom/brightness" = {
              format =  " [█████░░░░░]50%";
              tooltip = false;
              class = "brightness";
            };
          }
        ];
      };
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;

        preload = [ "~/Pictures/Wallpapers/nix-m3j7q9_3440x1440.png" ];
        wallpaper = [ "DP-1,~/Pictures/Wallpapers/nix-m3j7q9_3440x1440.png" "HDMI-A-1,~/Pictures/Wallpapers/nix-m3j7q9_1920x1080.png" ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;

      settings = {
        "$mod" = "SUPER";
        bind =
        [
          "$mod, W, exec, ~/.config/hypr/scripts/waybar-toggle.sh"
          "$mod, space, exec, rofi -show drun"
          "$mod, B, exec, librewolf"
          "$mod, Return, exec, alacritty"
          "$mod, Q, killactive,"
          "$mod, F, fullscreen,"

          # Focus window
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, k, movefocus, u"
          "$mod, j, movefocus, d"

          # Move window
          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, l, movewindow, r"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, j, movewindow, d"

          # Toggle floating
          "$mod SHIFT, space, togglefloating,"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..4} to [move to] workspace {1..4}
          builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          4)
        );
      };
    };
  };
}