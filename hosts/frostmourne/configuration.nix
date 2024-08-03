{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./../../os/nixld.nix

    inputs.nixos-hardware.nixosModules.asus-zephyrus-gu603h
  ];

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

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # fingerprint (Broken)
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # wifi
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Enable dwm
  services.xserver.windowManager.dwm.enable = true;
  services.xserver.windowManager.dwm.package = pkgs.dwm.overrideAttrs {
    src = ./../../os/dwm;
  };

  # Enable awesome
  services.xserver.windowManager.awesome.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "gnome-xorg"; # "gnome" | "gnome-xorg"
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    # gnome-console # Problems with nautilus without this
  ];
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.peripherals.touchpad]
    click-method='default'
  '';

  programs.dconf.enable = true;
  programs.dconf.profiles = {
    gdm.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            text-scaling-factor = 1.5;
          };
        };
      }
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:alt_shift_toggle";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.blueman.enable = true;
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

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # TODO Unfortunately needed for obsidian, remove when fixed
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;

  programs.nh = {
    enable = true;
    flake = "/home/saegl/projects/nix/nixos";
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
    # wayland
    wl-clipboard # wayland clipboard for nvim
    wev # check keycode
    # gnome
    gnome.gnome-tweaks
    # dwm
    dmenu
    # compositor for awesomewm
    picom
  ];

  # Virt
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

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
