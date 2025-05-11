{ alacrittyConfigFile }: { config, pkgs, ... }:
let
  alacrittyTheme = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "master";
    sha256 = "sha256-3/NrywVhUfw5l8pkZdm6XqFFMcDl9DLB/ss5qF/MzsM=";
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
