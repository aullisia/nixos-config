{ pkgs, ... }:

with pkgs;
[
  # System / Utilities
  arrpc
  xdg-utils

  # Development
  dotnet-sdk_9
  jdk21
  jdk17

  # Other
  wireguard-tools
]
