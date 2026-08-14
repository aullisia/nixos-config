{
  den,
  inputs,
  lib,
  ...
}:
{
  # Setup for den
  flake-file.inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";
  # mkForce: flake-file's own dendritic.nix sets this to "github:denful/den"
  # with the same lib.mkDefault priority, which would otherwise be a
  # conflicting-definition error in `nix flake check`.
  flake-file.inputs.den.url = lib.mkForce "github:vic/den";
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  # den specific setup
  den = {
    schema.user.includes = [ den._.mutual-provider ];
    schema.host.includes = [
      {
        # Global home-manager options for all hosts (old: den.ctx.hm-host.nixos.home-manager)
        nixos.home-manager = {
          # For hosts with home manager users, automatically make home manager use host's nixpkgs
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
          # Removes current backup file before backing up
          # to avoid home manager switch errors
          backupCommand = "bash -c 'rm -f \"$1.bak\" && mv \"$1\" \"$1.bak\"' --";
          # Home manager modules
          sharedModules = [
            inputs.spicetify-nix.homeManagerModules.default
            inputs.nix-index-database.homeModules.default
          ];
        };
      }
    ];
    schema.user.classes = [ "homeManager" ];
    default = {
      nixos.system.stateVersion = "26.05";
      homeManager.home.stateVersion = "26.05";
      includes = [
        # Automatically sets home.username, home.homeDirectory, users.users.<name>
        den._.define-user
        # Makes user admin (wheel and networkmanager)
        den._.primary-user
        # Sets shell for user at OS and HM level
        (den._.user-shell "zsh")
        # Provides per system inputs'
        # i.e environment.systemPackages = [ inputs'.nixpkgs.legacyPackages.hello ]
        den._.inputs'
        # Provides per system self'
        den._.self'
        # Automatically sets networking.hostName from host name
        den._.hostname
      ];
    };
  };
}
