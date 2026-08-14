{ lib, stdenvNoCC, fetchFromGitHub, kdePackages }:

stdenvNoCC.mkDerivation {
  pname = "andromeda-launcher";
  version = "unstable-2025-03";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "AndromedaLauncher";
    rev = "6bd0ac4";
    hash = "sha256-MSYD8eH6m4vWfvoAfHkqMed+ZGjFE0Ln75cqIZYq9Eg=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/plasmoids/com.github.eliverlara.andromedalaauncher
    cp -r contents metadata.json translate \
      $out/share/plasma/plasmoids/com.github.eliverlara.andromedalaauncher/

    runHook postInstall
  '';

  meta = {
    description = "A simple launcher for KDE Plasma 6";
    homepage = "https://github.com/EliverLara/AndromedaLauncher";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
