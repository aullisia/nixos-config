# AUL's NixOS Configuration
My personal NixOS configuration

# Installation Guide
> ⚠️ Replace the included hardware-configuration.nix inside the host with one generated for your hardware. You can generate one using ``nixos-generate-config``.

Hosts:
 - vivonix

Build the flake with:
- ``
sudo nixos-rebuild switch --flake <path>#<hostname>
``
- example
``
sudo nixos-rebuild switch --flake .#vivonix
``
- After the initial build use ``./rebuild.sh``