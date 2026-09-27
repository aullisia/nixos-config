{
  lib,
  electron_43,
  # gclient2nix-generated dependency set for winboat-org/electron. See README.md
  # ("Lean Electron fork") for how to produce it.
  infoFile ? ./electron-winboat-info.json,
}:

# EXPERIMENTAL. Upstream's own Electron: winboat-org/electron, branch
# winboat-43.2.0, tag winboat-v43.2.0-1, commit c328b030fd3357139f66c8a3a84a4384c0136eed,
# rebased on Electron 43.2.0 (upstream 9b58e96340a34cccaccc08e410e76838b50b0cb2,
# Chromium 150.0.7871.129, Node 24.18.0).
#
# It is a *lean* build, not a functional fork: the GN args below strip browser
# features WinBoat never uses. Upstream measures 44.6 MiB (12.5%) less
# whole-tree PSS and ~20 MB less on disk. Nothing in WinBoat requires it, and
# `bun run dev` uses stock Electron 43.2.0 for API/ABI parity — so
# package.nix defaults to nixpkgs' electron_43.
#
# Why this needs a generated info file: nixpkgs' electron_43 is a from-source
# Chromium build whose gclient dependency set (pkgs/development/tools/electron/
# info.json) currently pins Electron 43.6.0 / Chromium 150.0.7871.250, while the
# fork carries revision-specific Chromium and Node patches for 150.0.7871.129.
# Those patch series are applied automatically by nixpkgs' common.nix (it walks
# src/electron/patches/config.json), but only if every gclient revision matches
# the fork's DEPS. Hence: regenerate the whole info set against the fork.
#
# Cost warning: this is a full Chromium build (hours, big-parallel, ~32 GB RAM,
# >150 GB scratch) and it does not reproduce upstream's PGO/ThinLTO profile.

let
  info =
    if builtins.pathExists infoFile then
      lib.importJSON infoFile
    else
      throw ''
        electron-winboat requires ${toString infoFile}, a gclient2nix dependency
        set for winboat-org/electron at tag winboat-v43.2.0-1. Generate it with
        the same tooling nixpkgs uses for electron (pkgs/development/tools/
        electron/update.py, which drives gclient2nix) pointed at the fork, then
        keep info.version = "43.2.0".
      '';

  # Translated from build/args/winboat.gn of the fork. nixpkgs' electron
  # expression already supplies the equivalent of build/args/release.gn, so only
  # the deltas are applied here.
  leanGnFlags = {
    # Size-oriented release build.
    optimize_for_size = true;
    use_relative_vtables_abi = true;
    symbol_level = 0;
    blink_symbol_level = 0;
    v8_symbol_level = 0;

    # Browser UI surfaces WinBoat does not use.
    enable_pdf_viewer = false;
    enable_pdf = false;
    enable_pdf_ink2 = false;
    enable_pdf_save_to_drive = false;
    enable_electron_extensions = false;
    enable_builtin_spellchecker = false;
    enable_printing = false;
    enable_plugins = false;
    enable_background_mode = false;

    # Image/AI/speech/XR.
    enable_jxl_decoder = false;
    use_on_device_model_service = false;
    webnn_use_tflite = false;
    webnn_use_litert = false;
    enable_speech_service = false;
    enable_browser_speech_service = false;
    enable_vr = false;
    use_bluez = false;
    use_udev = false;

    # WebGPU/Dawn and Chromium Vulkan; ANGLE Vulkan stays for SwiftShader.
    use_dawn = false;
    skia_use_dawn = false;
    enable_vulkan = false;
    angle_enable_vulkan = true;

    # Media: FreeRDP is a separate process, Chromium decodes nothing.
    use_vaapi = false;
    enable_gpu_channel_media_capture = false;
    chrome_wide_echo_cancellation_supported = false;
    proprietary_codecs = false;
    ffmpeg_branding = "Chromium";
    enable_library_cdms = false;
    enable_media_remoting = false;
    enable_media_remoting_rpc = false;
    enable_hls_demuxer = false;
    enable_dav1d_decoder = false;
    enable_av1_decoder = false;
    enable_libaom = false;
    media_use_symphonia = false;
    media_use_libvpx = false;
    media_use_openh264 = false;
    media_use_ffmpeg = false;
    use_alsa = false;
    use_pulseaudio = false;
    # media_use_ffmpeg = false makes nixpkgs' is_component_ffmpeg invalid.
    is_component_ffmpeg = false;
    rtc_use_h264 = false;

    # WebRTC surface without codecs, audio processing or data channels.
    rtc_builtin_ssl_root_certificates = false;
    rtc_include_opus = false;
    rtc_exclude_audio_processing_module = true;
    rtc_include_builtin_audio_codecs = false;
    rtc_include_dav1d_in_internal_decoder_factory = false;
    rtc_enable_sctp = false;
    rtc_build_dcsctp = false;
    rtc_build_libvpx = false;
    rtc_build_opus = false;
    rtc_use_x11 = false;
    rtc_use_x11_extensions = false;
    rtc_use_pipewire = false;
    rtc_video_psnr = false;
    rtc_build_examples = false;
    rtc_build_tools = false;

    # Network services. WebSockets and the HSTS preload list stay enabled.
    use_kerberos = false;
    enable_mdns = false;
    enable_reporting = false;
    enable_device_bound_sessions = false;
    enable_disk_cache_sql_backend = false;

    # Desktop Chrome services.
    enable_background_contents = false;
    enable_message_center = false;
    enable_chrome_notifications = false;
    enable_captive_portal_detection = false;
    enable_compute_pressure = false;
    enable_compose = false;
    enable_lens_desktop = false;
    enable_on_device_translation = false;
    enable_paint_preview = false;
    enable_session_service = false;
    enable_memory_coordinator_internals = false;
    enable_bound_session_credentials = false;
    enable_remoting = false;
    use_cups = false;
    use_cups_ipp = false;
    use_mpris = false;
    enable_webui_certificate_viewer = false;

    # Node.js and V8. Sparkplug, TurboFan, WebAssembly and the inspector stay.
    node_use_amaro = false;
    node_use_sqlite = false;
    v8_enable_temporal_support = false;
    v8_enable_maglev = false;
  };
in
(electron_43.unwrapped.override { inherit info; }).overrideAttrs
  (previousAttrs: {
    pname = "electron-winboat";

    gnFlags = previousAttrs.gnFlags // leanGnFlags;

    meta = previousAttrs.meta // {
      description = "WinBoat's lean Electron 43.2.0 build";
      homepage = "https://github.com/winboat-org/electron";
      platforms = [ "x86_64-linux" ]; # upstream fork supports linux-x64 only
      hydraPlatforms = [ ];
    };
  })
