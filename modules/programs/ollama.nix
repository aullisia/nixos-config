{ den, ... }:
{
  den.aspects.ollama.nixos =
  { pkgs, ... }:
  {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      user = "ollama";
      group = "ollama";
      modelsDir = "/var/lib/ollama-models";
    };
  };
}