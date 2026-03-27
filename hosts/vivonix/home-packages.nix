{ pkgs, ... }:

with pkgs;

[
  # System / Utilities
  (nemo-with-extensions.override {
    extensions = [ nemo-fileroller ];
  })
  nemo-fileroller
  winetricks
  # wineWow64Packages.stable
  wineWow64Packages.waylandFull

  # Editors / IDEs / Development
  arduino-ide
  # godot_4_4-mono
  godot_4_6-mono
  jetbrains.idea-ultimate
  jetbrains.rider
  jetbrains.webstorm
  jetbrains-toolbox
  blender
  { isFlatpak = true; appId = "org.vinegarhq.Vinegar"; origin = "flathub";  }

  # Office / Productivity
  hunspell
  hunspellDicts.nl_NL
  libreoffice-qt
  obsidian

  # Image / Media
  qimgv
  vlc
  pinta

  # Communication
  vesktop
  { isFlatpak = true; appId = "org.ferdium.Ferdium"; origin = "flathub";  }

  # Gaming
  prismlauncher
  { isFlatpak = true; appId = "org.vinegarhq.Sober"; origin = "flathub";  }
  gamescope
]
