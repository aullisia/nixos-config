{ config, vars, ... }:

{
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  users.users."${vars.user}".extraGroups = [ "storage" ];
}