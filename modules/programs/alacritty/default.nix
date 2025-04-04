{ alacrittyConfigFile }: { config, pkgs, ... }:
let
  alacrittyTheme = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "master";
    sha256 = "sha256-1KSItYOIPjJzltYZyL0nB4UtNWrjSNyihlBQp3VKaBg=";
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
