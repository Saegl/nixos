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

    inputs.nixos-hardware.nixosModules.asus-zephyrus-gu603h
  ];

  gnome.enable = false;
  virt.enable = false;
  nixld.enable = false;

  # Very experimental
  # hardware.nvidia.powerManagement.enable = true;
  # hardware.nvidia.powerManagement.finegrained = true;

  boot.initrd.verbose = false;
  boot.plymouth.enable = true;
  boot.consoleLogLevel = 0;
  boot.kernelParams = ["quiet" "udev.log_level=0"];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 10;
    timeoutStyle = "hidden"; # hold shift to show nixos generations
    splashImage = null;
  };

  networking.hostName = "frostmourne";
  networking.firewall.enable = false;
  time.timeZone = "Asia/Ashgabat"; # Return to "Asia/Almaty" when updated from +6 to +5
  i18n.defaultLocale = "en_US.UTF-8";

  # wifi
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = false;
  hardware.opengl.driSupport32Bit = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:alt_shift_toggle";

  services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

  # Enable sound.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ssh
  services.openssh = {
    enable = false;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  users.users.saegl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaWBr2618KejWiq3p373VmSfnbHaccI2U6OGUe2zsMD nix-on-droid"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.fish.enable = true;
  users.users.saegl = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
    ];
    createHome = true;
  };
  users.users.alisher = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
    ];
    createHome = true;
  };

  services.asusd.enable = true;
  environment.systemPackages = with pkgs; [
    # basic
    wget
    htop
    killall
    asusctl
    nix-index
    xclip # x11 clipboard for nvim
    lshw
    lsof
    # wayland
    wl-clipboard # wayland clipboard for nvim
    wev # check keycode
  ];

  # PS4 dualshock
  boot.kernelModules = ["uinput"];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];

  # NEVER CHANGE
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
