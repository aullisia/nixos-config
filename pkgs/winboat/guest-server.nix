# WinBoat 1.0 builds two guest binaries: the API server and the updater
# service that unpacks server-side updates pushed from the host on port 7150.
# Cross-compiled to windows/amd64 (upstream build-guest-server.sh produces
# dist/oem/{server,updater}/*.exe).
{
  lib,
  buildGoModule,
  buildPackages,
  winboat,
}:

let
  go = buildPackages.go.overrideAttrs (previousAttrs: {
    env = previousAttrs.env // {
      CGO_ENABLED = 0;
    };
  });
in
buildGoModule.override { inherit go; } {
  pname = "winboat-guest-server";
  inherit (winboat) version src;
  modRoot = "guest_server";

  vendorHash = "sha256-NjjQINg+qh5zsGoPlpbw9Ib29+KhIuSYXPr6fU+JZjg=";

  # 1.0 builds two binaries: the guest API server and the updater service that
  # unpacks server-side updates pushed from the host.
  subPackages = [
    "cmd/server"
    "cmd/updater"
  ];

  env = {
    GOOS = "windows";
    GOARCH = "amd64";
  };

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${winboat.version}"
    "-X main.CommitHash=${builtins.substring 0 7 winboat.src.rev}"
  ];

  # build-guest-server.sh names the binaries after their install locations.
  postInstall = ''
    mv $out/bin/server* $out/bin/winboat_guest_server.exe
    mv $out/bin/updater* $out/bin/winboat_guest_server_updater.exe
  '';

  meta = {
    mainProgram = "winboat_guest_server.exe";
    description = "Guest server and guest server updater for winboat";
    homepage = "https://github.com/winboat-org/winboat";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-windows" ];
  };
}