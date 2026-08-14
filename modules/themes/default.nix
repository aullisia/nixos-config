# Theme provider — exposes the active theme's data as `config.modules.theme`
# in BOTH the NixOS and Home Manager module scopes (each consumer reads the
# fields it needs with `or` fallbacks, so nothing breaks if the themes aspect
# is removed or a field is missing).
#
# To switch themes, edit `_theme/select.nix` — it imports exactly one theme
# file (e.g. `./catppuccin-mocha-lavender.nix`). The theme files themselves
# live in `_theme/` so denix's import-tree doesn't auto-register them as
# aspects.
{ den, ... }:
{
  den.aspects.themes = {
    nixos =
      { ... }:
      {
        imports = [ ./_theme/select.nix ];
      };

    homeManager =
      { ... }:
      {
        imports = [ ./_theme/select.nix ];
      };
  };
}
