# WinBoat 1.0 always launches a bundled FreeRDP client and only falls back to a
# system client when the user opts in. Upstream ships a static musl build from
# an authenticated GitHub Actions artifact; this builds the same source revision
# dynamically against nixpkgs.
#
# Source: winboat-org/WBFreeRDP, branch winboat-3.30 = FreeRDP 3.30.0 plus 24
# RemoteApp/X11 patches (live resize, clipboard chunking, keyboard layout
# detection, Compose/dead keys, suspend-resume reconnect, ...).
#
# Only the runtime check `xfreerdp /version` containing "version 3." is enforced
# by WinBoat itself; the manifest/SHA-256 checks live in the packaging scripts,
# which package.nix removes.
{
  lib,
  fetchFromGitHub,
  freerdp,
}:

let
  rev = "9e3f5a9d49a9fbf02f449122934fdfd027dbed53";
in
(freerdp.override {
  buildServer = false;
  withUnfree = false;
}).overrideAttrs
  (previousAttrs: {
    pname = "wbfreerdp";
    version = "3.30.0-winboat-${builtins.substring 0 9 rev}";

src = fetchFromGitHub {
      owner = "winboat-org";
      repo = "WBFreeRDP";
      inherit rev;
      hash = "sha256-x4czU/O+TbLkCG1H+p4sp3S3YM9Y/0zb657A62UeCPg=";
    };

    # nixpkgs' freerdp expression tracks 3.31.x. If a substituteInPlace in its
    # postPatch or a cmake option no longer matches 3.30.0, adjust here.
    cmakeFlags = previousAttrs.cmakeFlags ++ [
      (lib.cmakeBool "WITH_CLIENT_SDL" false)
      (lib.cmakeBool "WITH_SHADOW" false)
    ];

    passthru = { };

    meta = previousAttrs.meta // {
      description = "WinBoat's FreeRDP 3.30 fork with RemoteApp and X11 fixes";
      homepage = "https://github.com/winboat-org/WBFreeRDP";
      mainProgram = "xfreerdp";
      platforms = [ "x86_64-linux" ];
    };
  })