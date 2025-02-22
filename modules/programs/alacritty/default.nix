{ alacrittyConfigFile }: { config, pkgs, ... }:
let
  alacrittyTheme = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "master";
    sha256 = "sha256-3SNuamNrV26KQboBBSniAF/C97E2OUNHjpnb9vGHu6I=";
  };
in
{
 home.packages = with pkgs; [ 
    alacritty
  ];
  
  home.file.".config/alacritty/themes" = {
    source = alacrittyTheme;
  };

  home.file.".config/alacritty/alacritty.toml" = {
    source = alacrittyConfigFile;
    # onChange = builtins.readFile ./alacritty.sh; # TODO
  };
}