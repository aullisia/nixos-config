{ pkgs }:

{
  browser = "${pkgs.librewolf}/bin/librewolf";
  terminal = "${pkgs.ghostty}/bin/ghostty";
  fileManager = "${pkgs.nemo}/bin/nemo";
  appLauncher = "${pkgs.walker}/bin/walker";

  # screenshotArea = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim -g \"\\\$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";
  # screenshotWindow = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim -g \"\\\$(${pkgs.slurp}/bin/slurp -w)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";
  # screenshotOutput = "${pkgs.bash}/bin/bash -c '${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy'";
}