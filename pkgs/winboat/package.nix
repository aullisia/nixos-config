# WinBoat 1.0 beta (1.0-bleeding-edge @ 32eceed, version 1.0.9), built from source.
#
# Upstream ships only a bun.lock (no package-lock.json) and uses bun-specific
# `patchedDependencies` (usb@2.18.0 C++14->C++17). Nixpkgs' buildNpmPackage is
# kept viable by vendoring a generated package-lock.json and applying the usb
# patch manually in preBuild. See ./README.md (on disk next to these files in
# the original package set) for the full write-up and the hash placeholders.
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  callPackage,
  pkgsCross,
  nodejs_24,
  electron_43,
  makeWrapper,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  zip,
  pkg-config,
  udev,
  glib,
  gtk3,
  gsettings-desktop-schemas,
  usbutils,
  freerdp,
  docker-compose,
  podman-compose,
  xdg-utils,

  # Path to the extracted Helios WDDM/GPU bundle. Null disables GPU
  # acceleration (upstream's install.bat guards with `if exist`, so this is
  # safe). The bundle is upstream CI artifact
  # `helios-windows-x64-22.22.288.0` (run 34785908809 of winboat-org/helios),
  # which expires after 90 days and has no stable URL — ship it locally via
  # ./helios.nix. Set this via the winboat NixOS module (modules/programs/
  # winboat.nix, option `winboat.gpu.heliosBundle`).
  heliosBundle ? null,

  # Build against upstream's lean Electron fork instead of nixpkgs' electron_43.
  # Requires a generated gclient2nix info file; see ./electron-winboat.nix.
  useLeanElectron ? false,
  electron-winboat ? callPackage ./electron-winboat.nix { },
}:

let
  electron = if useLeanElectron then electron-winboat else electron_43;
in
buildNpmPackage (finalAttrs: {
  pname = "winboat";
  # 1.0-bleeding-edge branch; upstream package.json says 1.0.9
  version = "1.0.9-unstable-2026-10-04";

  src = fetchFromGitHub {
    owner = "winboat-org";
    repo = "winboat";
    rev = "f098ba91a45fb38183bedae2c8cdacd50af941aa";
    hash = "sha256-e2XF8DXfNOHSL9N3luDkveKwtGwrlMCxiY6dZG7bzmA=";
  };

  nodejs = nodejs_24; # package.json engines: node >=23.6.0, .npmrc sets engine-strict

  # Upstream ships only bun.lock and has no npm lockfile. The vendored
  # package-lock.json is generated from package.json (see README.md); it must be
  # regenerated whenever upstream dependencies change.
  npmDepsHash = "sha256-25Nlo0lfPZFzAF3HpMljC96Dc1SA9dGe1B4bidGHHmk=";
  makeCacheWritable = true;

  # The hook's `npm rebuild` would run usb's install script before the C++
  # standard patch below can be applied.
  npmRebuildFlags = [ "--ignore-scripts" ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
    zip
    pkg-config
  ];

  buildInputs = [
    udev # vendored libusb in usb@2.18.0 links against libudev
    glib
    gtk3
    gsettings-desktop-schemas
  ];

  dontWrapGApps = true;
  # Do not let the generic fixup shrink the RPATHs of the Electron runtime that
  # electron-builder copied into dist/linux-unpacked.
  dontPatchELF = true;

  guest-server = pkgsCross.mingwW64.callPackage ./guest-server.nix {
    winboat = finalAttrs.finalPackage;
  };
  wbfreerdp = callPackage ./wbfreerdp.nix { };

  passthru = {
    inherit (finalAttrs) guest-server wbfreerdp;
    inherit electron;
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json

    # beforePack downloads the prebuilt WBFreeRDP bundle and afterPack rejects
    # any Electron binary whose SHA-256 differs from upstream's published fork.
    # Both inputs are built from source here.
    substituteInPlace electron-builder.json \
      --replace-fail '"beforePack": "scripts/before-pack.mjs",' "" \
      --replace-fail '"afterPack": "scripts/after-pack.mjs",' ""

    substituteInPlace scripts/build.ts \
      --replace-fail 'import { prepareFreeRDP } from "./prepare-freerdp.mjs";' "" \
      --replace-fail 'await Promise.all([buildRenderer(), buildMain(), prepareFreeRDP()]);' \
        'await Promise.all([buildRenderer(), buildMain()]);'

    # Generated desktop shortcuts bake in process.execPath, which is the
    # unwrapped Electron binary and therefore misses the runtime PATH.
    substituteInPlace src/renderer/lib/shortcut-files.ts \
      --replace-fail 'if (env.APPIMAGE) return { type: "appimage", executable: env.APPIMAGE, args: [] };' \
        'if (env.WINBOAT_LAUNCHER) return { type: "bin", executable: env.WINBOAT_LAUNCHER, args: [] };
    if (env.APPIMAGE) return { type: "appimage", executable: env.APPIMAGE, args: [] };'
  '';

  preBuild = ''
    # usb@2.18.0 ships prebuilt N-API binaries linked against the host libudev,
    # so it is rebuilt from source. Upstream raises the C++ standard through
    # bun's patchedDependencies (patches/usb@2.18.0.patch), which npm ignores;
    # node-addon-api 8 requires C++17.
    substituteInPlace node_modules/usb/binding.gyp \
      --replace-fail "'-std=c++14'" "'-std=c++17'"
    npm_config_build_from_source=true npm rebuild usb --foreground-scripts
    rm -rf node_modules/usb/prebuilds
  '';

  buildPhase = ''
    runHook preBuild

    # Stage the guest payload that build-guest-server.sh produces.
    mkdir -p guest_server/dist/oem/server/scripts \
             guest_server/dist/oem/updater \
             guest_server/dist/update
    install -Dm755 ${finalAttrs.guest-server}/bin/winboat_guest_server.exe \
      guest_server/dist/oem/server/winboat_guest_server.exe
    install -Dm755 ${finalAttrs.guest-server}/bin/winboat_guest_server_updater.exe \
      guest_server/dist/oem/updater/winboat_guest_server_updater.exe
    cp guest_server/scripts/apps.ps1 \
       guest_server/scripts/get-icon.ps1 \
       guest_server/scripts/validate-app.ps1 \
       guest_server/scripts/path-utils.ps1 \
       guest_server/scripts/time-sync.bat \
       guest_server/dist/oem/server/scripts/
    cp guest_server/install.bat guest_server/nssm.exe guest_server/RDPApps.reg \
       guest_server/dist/oem/
    (cd guest_server/dist/oem/server && zip -r -q ../../update/winboat_guest_server.zip .)

    # Stage the Helios WDDM/GPU bundle when one is provided. install.bat (via
    # the `if exist` guard) and the installer only enable GPU when this is
    # present; without it GPU acceleration is simply unavailable.
    ${
      if heliosBundle != null then
        ''
          mkdir -p guest_server/dist/oem/helios
          cp -a ${heliosBundle}/. guest_server/dist/oem/helios/
        ''
      else
        ''
          echo "WinBoat: no helios bundle staged; GPU acceleration disabled."
        ''
    }

    # Fill the bundled-FreeRDP cache path that electron-builder's extraResources
    # entry already points at.
    install -Dm755 ${finalAttrs.wbfreerdp}/bin/xfreerdp \
      .cache/freerdp/linux-x64/wbfreerdp/xfreerdp

    node scripts/build.ts

    npm exec -- electron-builder --linux --dir \
      -c.electronDist=${electron.dist} \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # 1.0 resolves its payload through process.resourcesPath (guest_server/,
    # data/) and app.isPackaged (freerdp/), so the unpacked distribution is
    # installed as-is instead of running electron against a bare app.asar.
    mkdir -p $out/bin $out/share/winboat
    cp -r dist/linux-unpacked/. $out/share/winboat/
    test -x $out/share/winboat/winboat

    install -Dm444 icons/winboat_logo.svg \
      $out/share/icons/hicolor/scalable/apps/winboat.svg

    gappsWrapperArgsHook
    makeWrapper $out/share/winboat/winboat $out/bin/winboat \
      "''${gappsWrapperArgs[@]}" \
      --set WINBOAT_LAUNCHER $out/bin/winboat \
      --set CHROME_DEVEL_SANDBOX $out/share/winboat/chrome-sandbox \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --suffix PATH : ${
        lib.makeBinPath [
          usbutils
          docker-compose
          podman-compose
          freerdp # only used when "Use system FreeRDP" is enabled
          xdg-utils
        ]
      }

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "winboat";
      desktopName = "WinBoat";
      type = "Application";
      exec = "winboat %U";
      terminal = false;
      icon = "winboat";
      categories = [ "Utility" ];
    })
  ];

  meta = {
    mainProgram = "winboat";
    description = "Run Windows apps on Linux with seamless integration (1.0 beta)";
    homepage = "https://github.com/winboat-org/winboat";
    license = lib.licenses.mit;
    # guest_server/nssm.exe is a vendored prebuilt Windows binary.
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
})