{ den, ... }:
{
  den.aspects.vscode.homeManager =
    { pkgs, config, lib, ... }:
    {
      home.packages = with pkgs; [
        vscode
      ];

      home.file.".vscode/argv.json".text = builtins.toJSON {
        password-store = "gnome-libsecret";
        enable-crash-reporter = false;
      };
    };
}
