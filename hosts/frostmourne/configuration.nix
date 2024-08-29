{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./../../os/gnome.nix
    ./../../os/virt.nix
    ./../../os/nixld.nix
    ./../../os/nix.nix
    ./../../os/bluetooth.nix
    ./../../os/sound.nix
    ./../../os/boot.nix
    ./../../os/networking.nix
    ./../../os/x11.nix
    ./../../os/wayland.nix
    ./../../os/users.nix
    ./../../os/fonts.nix
    ./../../os/river.nix
    ./../../os/gaming.nix
    ./../../os/llm.nix

    inputs.nixos-hardware.nixosModules.asus-zephyrus-gu603h
  ];

  gnome.enable = false;
  virt.enable = false;
  nixld.enable = false;
  x11.enable = false;
  wayland.enable = true;
  river.enable = true;
  gaming.enable = true;
  llm.enable = true;

  # Very experimental
  # hardware.nvidia.powerManagement.enable = true;
  # hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.open = false;

  services.power-profiles-daemon.enable = true;

  time.timeZone = "Asia/Ashgabat"; # Return to "Asia/Almaty" when updated from +6 to +5
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.graphics.enable32Bit = true;

  services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

  # ssh
  services.openssh = {
    enable = false;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  users.users.saegl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaWBr2618KejWiq3p373VmSfnbHaccI2U6OGUe2zsMD nix-on-droid"
  ];

  services.asusd.enable = true;
  environment.systemPackages = with pkgs; [
    # basic
    wget
    htop
    killall
    asusctl
    lshw
    lsof
    neofetch
  ];

  # PS4 dualshock
  boot.kernelModules = ["uinput"];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  # NEVER CHANGE
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
