{ lib,
  stdenvNoCC,
  fetchFromBitbucket,
  gtk3,
  hicolor-icon-theme,
}:

stdenvNoCC.mkDerivation {
  pname = "yet-another-monochrome-icon-set";
  version = "1.3.8";

  src = fetchFromBitbucket {
    owner = "dirn-typo";
    repo = "yet-another-monochrome-icon-set";
    rev = "main";
    hash = "sha256-1UrfH4AH2+tlFgc13X1nacaBzbucPeF8N/1m9gDDf30=";
  };

  nativeBuildInputs = [ gtk3 ];

  propagatedBuildInputs = [
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/Yet-Another-Monochrome
    cp -r * $out/share/icons/Yet-Another-Monochrome

    gtk-update-icon-cache -f \
      $out/share/icons/Yet-Another-Monochrome || true

    runHook postInstall
  '';

  meta = {
    description = "Yet Another Monochrome Icon Set";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
