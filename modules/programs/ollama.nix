{ den, ... }:
{
  den.aspects.ollama.nixos =
  { pkgs, ... }:
  {
    services.ollama = {
      enable = true;
      user = "ollama";
      group = "ollama";
      modelsDir = "/var/lib/ollama-models";
    };
  };
}