{ config, pkgs, vars, ... }:

{
  # qemu
  environment.systemPackages = with pkgs; [
    qemu
    quickemu
  ];

  # virt-manager + libvirt
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "${vars.user}" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  systemd.services.libvirt-default-network = {
    description = "Start libvirt default network";
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.libvirt}/bin/virsh net-start default";
      ExecStop = "${pkgs.libvirt}/bin/virsh net-destroy default";
      User = "root";
    };
  };
}
