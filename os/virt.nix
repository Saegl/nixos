{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    virt.enable = lib.mkEnableOption "enable virtualisation";
  };
  config = lib.mkIf config.virt.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [
      qemu
      quickemu
    ];
  };
}
