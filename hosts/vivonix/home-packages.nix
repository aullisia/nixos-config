{ pkgs, ... }:

with pkgs;

[
  # System / Utilities
  (nemo-with-extensions.override {
    extensions = [ nemo-fileroller ];
  })
  nemo-fileroller
  

  # Editors / IDEs / Development
  arduino-ide
  godot_4_4-mono
  jetbrains.idea-ultimate
  jetbrains.rider
  jetbrains-toolbox
  { isFlatpak = true; appId = "org.vinegarhq.Vinegar"; origin = "flathub";  }

  # Office / Productivity
  hunspell
  hunspellDicts.nl_NL
  libreoffice-qt

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
]
