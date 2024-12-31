{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./../../os/osbundle.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-gu603h
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.saegl = import ./home.nix;
      home-manager.extraSpecialArgs = {inherit inputs;};
    }
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  gnome.enable = false;
  virt.enable = false;
  nixld.enable = true;
  x11.enable = false;
  wayland.enable = true;
  river.enable = true;
  gaming.enable = true;
  llm.enable = true;

  # Very experimental
  # hardware.nvidia.powerManagement.enable = true;
  # hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.open = false;

  services.power-profiles-daemon.enable = false;
  services.tlp.enable = false;
  services.auto-cpufreq.enable = false;

  time.timeZone = "Asia/Ashgabat"; # Return to "Asia/Almaty" when updated from +6 to +5
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.graphics.enable32Bit = true;

  services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

  # ssh
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.AllowUsers = ["*@192.168.*.*"];
  };
  users.users.saegl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOd0Z22qitTvXUwAVMAi5EyqV6b69flhLL28Cde2VpV nix-on-droid"
  ];

  services.asusd.enable = true;
  environment.systemPackages = with pkgs; [
    # basic
    wget
    htop
    man-pages
    killall
    asusctl
    lshw
    lsof
    neofetch
  ];

  # NEVER CHANGE
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
