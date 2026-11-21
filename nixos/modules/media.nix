{ ... }:

{
  users.groups.media = {
    gid = 2000;
  };

  users.users.rleblic.extraGroups = [ "media" ];
  users.users.plex.extraGroups = [ "media" ];

  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/09f64eaf-1f48-4d6b-9e2d-930219dee0b4";
    fsType = "ext4";

    options = [
      "rw"
      "noatime"
      "nofail"
    ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/media 172.26.0.0/24(rw,sync,root_squash,no_subtree_check,mountpoint)
    '';
  };

  services.nfs.settings.nfsd = {
    vers3 = false;
    vers4 = true;
    tcp = true;
    udp = false;
  };

  # Do not export the underlying directory when the media disk is unavailable.
  systemd.services.nfs-server.unitConfig.RequiresMountsFor = [ "/mnt/media" ];

  # NFSv4 needs only TCP 2049; do not open it globally or expose NFSv3 RPC ports.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -s 172.26.0.0/24 -p tcp --dport 2049 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -s 172.26.0.0/24 -p tcp --dport 2049 -j nixos-fw-accept 2>/dev/null || true
  '';
}
