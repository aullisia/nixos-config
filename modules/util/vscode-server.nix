{ den, inputs, ... }:
{
  den.aspects.vscode-server = {
    nixos = { ... }: {
      imports = [ inputs.vscode-server.nixosModules.default ];

      services.vscode-server.enable = true;
    };
  };
}
