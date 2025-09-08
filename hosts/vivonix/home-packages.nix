{ pkgs, ... }:

with pkgs;

[
  # System / Utilities
  nemo

  # Editors / IDEs / Development
  arduino-ide
  godot_4_4-mono
  jetbrains.idea-ultimate
  jetbrains.rider
  jetbrains-toolbox
  vscode
  { isFlatpak = true; appId = "org.vinegarhq.Vinegar"; origin = "flathub";  }

  # Office / Productivity
  hunspell
  hunspellDicts.nl_NL
  libreoffice-qt

  # Image / Media
  qimgv
  vlc

  # Communication
  vesktop

  # Gaming
  prismlauncher
  { isFlatpak = true; appId = "org.vinegarhq.Sober"; origin = "flathub";  }
]
