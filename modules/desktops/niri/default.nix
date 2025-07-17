{ wallpaper }: { config, pkgs, home-manager, vars, ... }:

# Used https://github.com/Sly-Harvey/NixOS/blob/master/modules/desktop/hyprland/programs/waybar/default.nix

{
	programs.niri = {
		enable = true;
		package = pkgs.niri;
	};

	environment.systemPackages = with pkgs; [
		xwayland-satellite
    pavucontrol
    pamixer
	];

  fonts.packages = with pkgs.nerd-fonts; [jetbrains-mono];

	home-manager.users."${vars.user}" = {
    imports =
    [
      ../../programs/walker
    ];

    home.packages = with pkgs; [ 
      bibata-cursors
    ];

    home.file.".config/niri" = {
      recursive = true;
      source = ./niri;
    };

    programs.waybar = {
      enable = true;

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 14px;
          font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
          margin: 0px;
          padding: 0px;
        }

                @define-color shadow rgba(0, 0, 0, 0.25);
        /*
        *
        * Catppuccin Mocha palette
        * Maintainer: rubyowo
        *
        */

        @define-color base   #1E1D2E;
        @define-color mantle #181825;
        @define-color crust  #11111b;

        @define-color text     #cdd6f4;
        @define-color subtext0 #a6adc8;
        @define-color subtext1 #bac2de;

        @define-color surface0 #313244;
        @define-color surface1 #45475a;
        @define-color surface2 #585b70;

        @define-color overlay0 #6c7086;
        @define-color overlay1 #7f849c;
        @define-color overlay2 #9399b2;

        @define-color blue      #89b4fa;
        @define-color lavender  #b4befe;
        @define-color sapphire  #74c7ec;
        @define-color sky       #89dceb;
        @define-color teal      #94e2d5;
        @define-color green     #a6e3a1;
        @define-color yellow    #f9e2af;
        @define-color peach     #fab387;
        @define-color maroon    #eba0ac;
        @define-color red       #f38ba8;
        @define-color mauve     #cba6f7;
        @define-color pink      #f5c2e7;
        @define-color flamingo  #f2cdcd;
        @define-color rosewater #f5e0dc;

        @define-color base_lighter  #1e1e2e;
        @define-color mauve_lighter #caa6f7;

        window#waybar {
          transition-property: background-color;
          transition-duration: 0.5s;
          background: transparent;
          border-radius: 0px;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        tooltip {
          background: #1e1e2e;
          border-radius: 8px;
        }

        tooltip label {
          color: #cad3f5;
          margin-right: 5px;
          margin-left: 5px;
        }

        .modules-center,
        .modules-right {
          background: @base;
          border: 1px solid @lavender;
          padding: 0px 10px;
          border-radius: 0px;
          margin-top: 5px
        }

        .modules-right {
          margin-right: 17px;
        }

        #idle_inhibitor,
        #clock,
        #tray,
        #bluetooth,
        #cpu,
        #memory,
        #pulseaudio,
        #pulseaudio-slider
        {
          padding-top: 3px;
          padding-bottom: 3px;
          padding-right: 6px;
          padding-left: 6px;
        }

        #idle_inhibitor, #bluetooth {
          color: @blue;
        }

        #custom-notification {
          color: #dfdfdf;
          padding: 0px 5px;
          border-radius: 5px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }
        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
        }

        #cpu {
          color: @yellow;
        }

        #memory {
         color: @green;
        }

        #pulseaudio {
          color: @lavender;
        }

        #pulseaudio.bluetooth {
          color: @pink;
        }
        #pulseaudio.muted {
          color: @red;
        }

        #pulseaudio-slider slider {
          min-width: 0px;
          min-height: 0px;
          opacity: 0;
          background-image: none;
          border: none;
          box-shadow: none;
        }

        #pulseaudio-slider trough {
          min-width: 80px;
          min-height: 5px;
          border-radius: 5px;
        }

        #pulseaudio-slider highlight {
          min-height: 10px;
          border-radius: 5px;
        }
      '';

      settings = [
        {
          layer = "top";
          position = "top";
          output = ["DP-1"];
          height = 30; 

          modules-left = [ ];
          modules-center = [ "idle_inhibitor" "clock" ];
          modules-right = [ "cpu" "memory" "pulseaudio" "bluetooth" "network" "tray" "custom/notification" ];

          "clock" = {
            format = "{:%a %d %b %R}";
            # format = "{:%R 󰃭 %d·%m·%y}";
            format-alt = "{:%I:%M %p}";
            tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              on-scroll = 1;
              on-click-right = "mode";
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span color='#ff6699'><b>{}</b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-click-forward = "tz_up";
              on-click-backward = "tz_down";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };

          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "󰥔";
              deactivated = "";
            };
          };

          "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "swaync-client -t -sw";
            on-click-right = "swaync-client -d -sw";
            escape = true;
          };

          "tray" = {
            icon-size = 14;
            spacing = 5;
          };

          "bluetooth" = {
            format = "";
            # format-disabled = ""; # an empty format will hide the module
            format-connected = " {num_connections}";
            tooltip-format = " {device_alias}";
            tooltip-format-connected = "{device_enumerate}";
            tooltip-format-enumerate-connected = " {device_alias}";
            on-click = "blueman-manager";
          };

          "network" = {
            # on-click = "nm-connection-editor";
            # "interface" = "wlp2*"; # (Optional) To force the use of this interface
            format-wifi = "󰤨 Wi-Fi";
            # format-wifi = " {bandwidthDownBits}  {bandwidthUpBits}";
            # format-wifi = "󰤨 {essid}";
            format-ethernet = "󱘖 Wired";
            # format-ethernet = " {bandwidthDownBits}  {bandwidthUpBits}";
            format-linked = "󱘖 {ifname} (No IP)";
            format-disconnected = "󰤮 Off";
            # format-disconnected = "󰤮 Disconnected";
            format-alt = "󰤨 {signalStrength}%";
            tooltip-format = "󱘖 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
          };

          "pulseaudio" = {
            format = "{icon} {volume}";
            format-muted = " ";
            on-click = "pavucontrol -t 3";
            tooltip-format = "{icon} {desc} // {volume}%";
            scroll-step = 4;
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
          };

          "pulseaudio#microphone" = {
            format = "{format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            on-click = "pavucontrol -t 4";
            tooltip-format = "{format_source} {source_desc} // {source_volume}%";
            scroll-step = 5;
          };

          "cpu" = {
            interval = 10;
            format = "󰍛 {usage}%";
            format-alt = "{icon0}{icon1}{icon2}{icon3}";
            format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
          };

          "memory" = {
            interval = 30;
            format = "󰾆 {percentage}%";
            format-alt = "󰾅 {used}GB";
            max-length = 10;
            tooltip = true;
            tooltip-format = " {used:.1f}GB/{total:.1f}GB";
          };

        }
      ];
    };

    services.swaync = {
      enable = true;
      settings = {
        "$schema" = "/etc/xdg/swaync/configSchema.json";
        positionX = "right";
        positionY = "top";
        cssPriority = "user";
        control-center-margin-top = 22;
        control-center-margin-bottom = 2;
        control-center-margin-right = 1;
        control-center-margin-left = 0;
        notification-icon-size = 64;
        notification-body-image-height = 128;
        notification-body-image-width = 200;
        timeout = 6;
        timeout-low = 3;
        timeout-critical = 0;
        fit-to-screen = false;
        control-center-width = 400;
        control-center-height = 915;
        notification-window-width = 375;
        keyboard-shortcuts = true;
        image-visibility = "when-available";
        transition-time = 200;
        hide-on-clear = false;
        hide-on-action = true;
        script-fail-notify = true;
        widgets = [
          "title"
          "dnd"
          "menubar#desktop"
          "volume"
          "mpris"
          "notifications"
          "buttons-grid"
        ];
        widget-config = {
          title = {
            text = " Quick settings";
            clear-all-button = true;
            button-text = "";
          };
          "menubar#desktop" = {
            "backlight" = {
              label = "       󰃟  ";
            };
            "menu#screenshot" = {
              label = "	󰄀   Screenshot	";
              position = "left";
              actions = [
                {
                  label = "Whole screen";
                  command = "niri msg action screenshot-screen";
                }
                {
                  label = "Select region";
                  command = "niri msg action screenshot";
                }
              ];
            };
            "menu#power" = {
              label = "	   Power Menu	  ";
              position = "left";
              actions = [
                {
                  label = "   Lock";
                  command = "swaylock";
                }
                {
                  label = "   Logout";
                  command = "niri msg action quit";
                }
                {
                  label = "   Shut down";
                  command = "systemctl poweroff";
                }
                {
                  label = "󰤄   Suspend";
                  command = "systemctl suspend";
                }
                {
                  label = "   Reboot";
                  command = "systemctl reboot";
                }
              ];
            };
          };
          volume = {
            label = "";
            expand-button-label = "";
            collapse-button-label = "";
            show-per-app = true;
            show-per-app-icon = true;
            show-per-app-label = true;
          };
          dnd = {
            text = " Do Not Disturb";
          };
          mpris = {
            image-size = 96;
            image-radius = 4;
          };
          label = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "";
          };

          "buttons-grid" = {
            actions = [
              {
                label = "󰝟";
                type = "toggle";
                command = "pamixer -t";
                update-command = "sh -c 'pamixer --get-mute | grep -q true && echo true || echo false'";
              }
              {
                label = "󰍭";
                type = "toggle";
                command = "pamixer --default-source -t";
                update-command = "sh -c 'pamixer --get-mute --default-source | grep true && echo true || echo false'";
              }
              {
                label = "󰤨";
                type = "toggle";
                command = "sh -c '[ \"$SWAYNC_TOGGLE_STATE\" = true ] && nmcli radio wifi on || nmcli radio wifi off'";
                update-command = "sh -c 'nmcli radio wifi | grep -q enabled && echo true || echo false'";
              }
              {
                label = "?";
              }
            ];
          };
        };
        scripts = {
          example-script = {
            exec = "echo 'Do something...'";
            urgency = "Normal";
          };
        };
        notification-visibility = {
          spotify = {
            state = "enabled";
            urgency = "Low";
            app-name = "Spotify";
          };
          youtube-music = {
            state = "enabled";
            urgency = "Low";
            app-name = "com.github.th_ch.youtube_music";
          };
        };
      };

      style = ''
        @define-color shadow rgba(0, 0, 0, 0.25);
        /*
        *
        * Catppuccin Mocha palette
        * Maintainer: rubyowo
        *
        */

        @define-color base   #1E1D2E;
        @define-color mantle #181825;
        @define-color crust  #11111b;

        @define-color text     #cdd6f4;
        @define-color subtext0 #a6adc8;
        @define-color subtext1 #bac2de;

        @define-color surface0 #313244;
        @define-color surface1 #45475a;
        @define-color surface2 #585b70;

        @define-color overlay0 #6c7086;
        @define-color overlay1 #7f849c;
        @define-color overlay2 #9399b2;

        @define-color blue      #89b4fa;
        @define-color lavender  #b4befe;
        @define-color sapphire  #74c7ec;
        @define-color sky       #89dceb;
        @define-color teal      #94e2d5;
        @define-color green     #a6e3a1;
        @define-color yellow    #f9e2af;
        @define-color peach     #fab387;
        @define-color maroon    #eba0ac;
        @define-color red       #f38ba8;
        @define-color mauve     #cba6f7;
        @define-color pink      #f5c2e7;
        @define-color flamingo  #f2cdcd;
        @define-color rosewater #f5e0dc;

        @define-color base_lighter  #1e1e2e;
        @define-color mauve_lighter #caa6f7;

        * {
          font-family: "Product Sans";
          background-clip: border-box;
        }

        /* #notifications_box { */
        /* border: solid 4px red; */
        /* } */

        label {
          color: @text;
        }

        .notification {
          border: none;
          box-shadow: none;
          /* margin: 0px; */
          /* margin: -15px -10px -15px -10px; */
          border-radius: 0px;
          background: inherit;
          /* background: @theme_bg_color; */
          /* background: shade(alpha(@borders, 2.55), 0.25); */
        }

        .notification button {
          background: transparent;
          border-radius: 0px;
          border: none;
          margin: 0px;
          padding: 0px;
        }

        .notification button:hover {
          /* background: @surface0; */
          background: @insensitive_bg_color;
        }

        .notification-content {
          min-height: 64px;
          margin: 10px;
          padding: 0px;
          border-radius: 0px;
        }

        .close-button {
          background: transparent;
          color: transparent;
        }

        .notification-default-action,
        .notification-action {
          background: transparent;
          border: none;
        }


        .notification-default-action {
          border-radius: 0px;
        }

        /* When alternative actions are visible */
        .notification-default-action:not(:only-child) {
          border-bottom-left-radius: 0px;
          border-bottom-right-radius: 0px;
        }

        .notification-action {
          border-radius: 0px;
          padding: 2px;
          color: @text;
          /* color: @theme_text_color; */
        }

        /* add bottom border radius to eliminate clipping */
        .notification-action:first-child {
          border-bottom-left-radius: 4px;
        }

        .notification-action:last-child {
          border-bottom-right-radius: 4px;
        }

        /*** Notification ***/
        /* Notification header */
        .summary {
          color: @text;
          /* color: @theme_text_color; */
          font-size: 14px;
          padding: 0px;
        }

        .time {
          color: @subtext0;
          /* color: alpha(@theme_text_color, 0.9); */
          font-size: 12px;
          text-shadow: none;
          margin: 0px 0px 0px 0px;
          padding: 2px 0px;
        }

        .body {
          font-size: 14px;
          font-weight: 500;
          color: @subtext1;
          /* color: alpha(@text, 0.9); */
          /* color: alpha(@theme_text_color, 0.9); */
          text-shadow: none;
          margin: 0px 0px 0px 0px;
        }

        .body-image {
          border-radius: 0px;
        }

        /* The "Notifications" and "Do Not Disturb" text widget */
        .top-action-title {
          color: @text;
          /* color: @theme_text_color; */
          text-shadow: none;
        }

        /* Control center */

        .control-center {
          background: alpha(@crust, .80);
          border-radius: 0px;

          border: 2px solid @lavender;

          box-shadow: 0 0 10px 0 rgba(0,0,0,.80);
          margin: 10px;
          padding: 4px;
          margin-top: -7px;
          margin-right: 16px;
        }

        /* .right.overlay-indicator { */
        /* border: solid 5px red; */
        /* } */

        .control-center-list {
          /* background: @base; */
          background: alpha(@crust, .80);
          min-height: 5px;
          /* border: 1px solid @surface1; */
          border-top: none;
          border-radius: 0px 0px 0px 0px;
        }

        .control-center-list-placeholder,
        .notification-group-icon,
        .notification-group {
          /* opacity: 1.0; */
          /* opacity: 0; */
          color: alpha(@theme_text_color, 0.50);
        }

        .notification-group {
          /* unset the annoying focus thingie */
          opacity: 0;
          box-shadow: none;
          /* selectable: no; */
        }

        .notification-group > box {
          all: unset;
          background: transparent;
          /* background: alpha(currentColor, 0.072); */
          padding: 4px;
          margin: 0px;
          /* margin: 0px -5px; */
          border: none;
          border-radius: 0px;
          box-shadow: none;
        }

        .notification-row {
          outline: none;
          transition: all 1s ease;
          background: alpha(@mantle, .80);
          /* background: @theme_bg_color; */
          border: 0px solid @crust;
          margin: 10px 5px 0px 5px;
          border-radius: 14px;
          /* box-shadow: 0px 0px 4px black; */
          /* background: alpha(currentColor, 0.05); */
        }

        .notification-row:focus,
        .notification-row:hover {
          box-shadow: none;
        }

        .control-center-list > row,
        .control-center-list > row:focus,
        .control-center-list > row:hover {
          background: transparent;
          border: none;
          margin: 0px;
          padding: 5px 10px 5px 10px;
          box-shadow: none;
        }

        .control-center-list > row:last-child {
          padding: 5px 10px 10px 10px;
        }


        /* Window behind control center and on all other monitors */
        .blank-window {
          background: transparent;
        }

        /*** Widgets ***/

        /* Title widget */
        .widget-title {
          margin: 0px;
          background: transparent;
          /* background: @theme_bg_color; */
          border-radius: 0px 0px 0px 0px;
          /* border: 1px solid @surface1; */
          border-bottom: none;
        }

        .widget-title > label {
          margin: 18px 10px;
          font-size: 20px;
          font-weight: 500;
        }

        .widget-title > button {
          font-weight: 700;
          padding: 7px 3px;
          margin-right: 10px;
          background: transparent;
          color: @text;
          /* color: @theme_text_color; */
          border: none;
          border-radius: 0px;
        }
        .widget-title > button:hover {
          background: @base;
          /* background: alpha(currentColor, 0.1); */
        }

        /* Label widget */
        .widget-label {
          margin: 0px;
          padding: 0px;
          min-height: 5px;
          background: alpha(@mantle, .80);
          /* background: @theme_bg_color; */
          border-radius: 0px 0px 0px 0px;
          /* border: 1px solid @surface1; */
          border-top: none;
        }
        .widget-label > label {
          font-size: 15px;
          font-weight: 400;
        }

        /* Menubar */
        .widget-menubar {
          background: transparent;
          /* background: @theme_bg_color; */
          /* border: 1px solid @surface1; */
          border-top: none;
          border-bottom: none;
        }
        .widget-menubar > box > box {
          margin: 5px 10px 5px 10px;
          min-height: 40px;
          border-radius: 0px;
          background: transparent;
        }
        .widget-menubar > box > box > button {
          background: alpha(@mantle, .80);
          /* background: alpha(currentColor, 0.05); */
          min-width: 185px;
          min-height: 50px;
          margin-right: 10px;
          font-size: 14px;
          padding: 0px;
        }
        .widget-menubar > box > box > button:nth-child(2) {
          margin-right: 0px;
        }
        .widget-menubar button:focus {
          box-shadow: none;
        }
        .widget-menubar button:focus:hover {
          background: @base;
          /* background: alpha(currentColor,0.1); */
          box-shadow: none;
        }

        .widget-menubar > box > revealer > box {
          margin: 5px 10px 5px 10px;
          background: alpha(@mantle, .80);
          /* background: alpha(currentColor, 0.05); */
          border-radius: 0px;
        }
        .widget-menubar > box > revealer > box > button {
          background: transparent;
          min-height: 50px;
          padding: 0px;
          margin: 5px;
        }

        /* Buttons grid */
        .widget-buttons-grid {
          /* background-color: @theme_bg_color; */
          background: transparent;
          /* border: 1px solid @surface1; */
          border-top: none;
          border-bottom: none;
          font-size: 14px;
          font-weight: 500;
          margin: 0px;
          padding: 5px;
          border-radius: 0px;
        }

        .widget-buttons-grid > flowbox > flowboxchild {
          background: alpha(@mantle, .80);
          /* background: alpha(currentColor, 0.05); */
          border-radius: 0px;
          min-height: 50px;
          min-width: 85px;
          margin: 5px;
          padding: 0px;
        }

        .widget-buttons-grid > flowbox > flowboxchild > button {
          background: transparent;
          border-radius: 0px;
          margin: 0px;
          border: none;
          box-shadow: none;
        }


        .widget-buttons-grid > flowbox > flowboxchild > button:hover {
          background: alpha(@mantle, .80);
          /* background: alpha(currentColor, 0.1); */
        }

        /* Mpris widget */
        .widget-mpris {
          padding: 8px;
          padding-bottom: 15px;
          margin-bottom: -33px;
        }
        .widget-mpris > box {
          padding: 0px;
          margin: -5px 0px -10px 0px;
          padding: 0px;
          border-radius: 0px;
          /* background: alpha(currentColor, 0.05); */
          background: alpha(@mantle, .80);
        }
        .widget-mpris > box > button:nth-child(1),
        .widget-mpris > box > button:nth-child(3) {
          margin-bottom: 0px;
        }
        .widget-mpris > box > button:nth-child(1) {
          margin-left: -25px;
          margin-right: -25px;
          opacity: 0;
        }
        .widget-mpris > box > button:nth-child(3) {
          margin-left: -25px;
          margin-right: -25px;
          opacity: 0;
        }

        .widget-mpris-album-art {
          all: unset;
        }

        /* Player button box */
        .widget-mpris > box > carousel > widget > box > box:nth-child(2) {
          margin: 5px 0px -5px 90px;
        }

        /* Player buttons */
        .widget-mpris > box > carousel > widget > box > box:nth-child(2) > button {
          border-radius: 0px;
        }
        .widget-mpris > box > carousel > widget > box > box:nth-child(2) > button:hover {
          background: alpha(currentColor, 0.1);
        }
        carouselindicatordots {
          opacity: 0;
        }

        .widget-mpris-title {
          color: #eeeeee;
          font-weight: bold;
          font-size: 1.25rem;
          text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.5);
        }
        .widget-mpris-subtitle {
          color: #eeeeee;
          font-size: 1rem;
          text-shadow: 0px 0px 3px rgba(0, 0, 0, 1);
        }

        .widget-mpris-player {
          border-radius: 0px;
          margin: 0px;
        }
        .widget-mpris-player > box > image {
          margin: 0px 0px -48px 0px;
        }

        .notification-group > box.vertical {
          /* border: solid 5px red; */
          margin-top: 3px
        }

        /* Backlight and volume widgets */
        .widget-backlight,
        .widget-volume {
          background: transparent;
          /* background-color: @crust; */
          /* background-color: @theme_bg_color; */
          /* border: 1px solid @surface1; */
          border-top: none;
          border-bottom: none; font-size: 13px;
          font-weight: 600;
          border-radius: 0px;
          margin: 0px;
          padding: 0px;
        }
        .widget-volume > box {
          background: alpha(@mantle, .80);
          /* background: alpha(currentColor, 0.05); */
          border-radius: 0px;
          margin: 5px 10px 5px 10px;
          min-height: 50px;
        }
        .widget-volume > box > label {
          min-width: 50px;
          padding: 0px;
        }
        .widget-volume > box > button {
          min-width: 50px;
          box-shadow: none;
          padding: 0px;
        }
        .widget-volume > box > button:hover {
          /* background: alpha(currentColor, 0.05); */
          background: @surface0;
        }
        .widget-volume > revealer > list {
          background: alpha(@mantle, .80);
          /* background: alpha(currentColor, 0.05); */
          border-radius: 0px;
          margin-top: 5px;
          padding: 0px;
        }
        .widget-volume > revealer > list > row {
          padding-left: 10px;
          min-height: 40px;
          background: transparent;
        }
        .widget-volume > revealer > list > row:hover {
          background: transparent;
          box-shadow: none;
          border-radius: 0px;
        }
        .widget-backlight > scale {
          background: alpha(@mantle, .80);
          /* background: alpha(currentColor, 0.05); */
          border-radius: 0px 0px 0px 0px;
          margin: 5px 10px 5px 0px;
          padding: 0px 10px 0px 0px;
          min-height: 50px;
        }
        .widget-backlight > label {
          background: @surface0;
          /* background: alpha(currentColor, 0.05); */
          margin: 5px 0px 5px 10px;
          border-radius: 0px 0px 0px 0px;
          padding: 0px;
          min-height: 50px;
          min-width: 50px;
        }

        /* DND widget */
        .widget-dnd {
          margin: 6px;
          font-size: 1.2rem;
        }

        .widget-dnd > switch {
          background: alpha(@mantle, .80);
          font-size: initial;
          border-radius: 0px;
          box-shadow: none;
          padding: 2px;
        }

        .widget-dnd > switch:hover {
          background: alpha(@mauve_lighter, .80);
        }

        .widget-dnd > switch:checked {
          background: @mauve;
        }

        .widget-dnd > switch:checked:hover {
          background: alpha(@mauve_lighter, .80);
        }

        .widget-dnd > switch slider {
          background: alpha(@mauve_lighter, .80);
          border-radius: 0px;
        }

        /* Toggles */
        .toggle:checked {
          background: @surface1;
          /* background: @theme_selected_bg_color; */
        }
        /*.toggle:not(:checked) {
          color: rgba(128, 128, 128, 0.5);
        }*/
        .toggle:checked:hover {
          background: @surface2;
          /* background: alpha(@theme_selected_bg_color, 0.75); */
        }

        /* Sliders */
        scale {
          padding: 0px;
          margin: 0px 10px 0px 10px;
        }

        scale trough {
          border-radius: 0px;
          background: @surface0;
          /* background: alpha(currentColor, 0.1); */
        }

        scale highlight {
          border-radius: 0px;
          min-height: 10px;
          margin-right: -5px;
        }

        scale slider {
          margin: -10px;
          min-width: 10px;
          min-height: 10px;
          background: transparent;
          box-shadow: none;
          padding: 0px;
        }
        scale slider:hover {
        }

        .right.overlay-indicator {
          all: unset;
        }
      '';
    };

    programs.swaylock = {
      enable = true;
      settings = {
        color = "24273a";
        bs-hl-color = "f4dbd6";
        caps-lock-bs-hl-color = "f4dbd6";
        caps-lock-key-hl-color = "a6da95";
        inside-color = "00000000";
        inside-clear-color = "00000000";
        inside-caps-lock-color = "00000000";
        inside-ver-color = "00000000";
        inside-wrong-color = "00000000";
        key-hl-color = "a6da95";
        layout-bg-color = "00000000";
        layout-border-color = "00000000";
        layout-text-color = "cad3f5";
        line-color = "00000000";
        line-clear-color = "00000000";
        line-caps-lock-color = "00000000";
        line-ver-color = "00000000";
        line-wrong-color = "00000000";
        ring-color = "b7bdf8";
        ring-clear-color = "f4dbd6";
        ring-caps-lock-color = "f5a97f";
        ring-ver-color = "8aadf4";
        ring-wrong-color = "ee99a0";
        separator-color = "00000000";
        text-color = "cad3f5";
        text-clear-color = "f4dbd6";
        text-caps-lock-color = "f5a97f";
        text-ver-color = "8aadf4";
        text-wrong-color = "ee99a0";
      };
    };

    services.swww = {
      enable = true;
    };
  };
}