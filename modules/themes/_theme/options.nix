# Shared interface for the theme data — the contract every consumer reads via
# `config.modules.theme.<field> or <fallback>`. Freeform on purpose: theme
# files stay trivial to write, and missing fields simply fall back at the
# consumer side.
{ lib, ... }:
{
  options.modules.theme = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = ''
      Active theme data — the single source of truth for system theming
      (Stylix scheme/cursor/icons/fonts, wallpaper, Noctalia palette,
      Plasma/SDDM theme, per-app theme names).

      Provided by the theme files in modules/themes/_theme and selected in
      modules/themes/_theme/select.nix. Consumers read individual fields with
      `or` fallbacks so a theme may omit fields, or the themes module may be
      absent entirely, without breaking anything.
    '';
  };
}
