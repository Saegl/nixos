{
  inputs,
  pkgs,
  config,
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
      home-manager.backupFileExtension = "backup2";
      home-manager.users.saegl = import ./home.nix;
      home-manager.extraSpecialArgs = {inherit inputs;};
    }
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"]; # Cross compile for arm

  gnome.enable = false;
  virt.enable = false;
  nixld.enable = true;
  x11.enable = false;
  wayland.enable = true;
  river.enable = false;
  gaming.enable = true;
  llm.enable = true;

  # Very experimental
  # hardware.nvidia.powerManagement.enable = true;
  # hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.tlp.settings = {
    # Aggressive power saving settings
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    SCHED_POWERSAVE_ON_BAT = 1;
    # NMI_WATCHDOG = 0;
    # DISK_DEVICES = "sda sdb";  # Replace with your actual disk devices
    # DISK_APM_LEVEL_ON_BAT = "128";  # 1-254, lower = more aggressive
    # DISK_SPINDOWN_TIMEOUT_ON_BAT = "12";  # 0–255, units of 5s
    # MAX_LOST_WORK_SECS_ON_BAT = 15;
    WIFI_PWR_ON_BAT = "on";
    PCIE_ASPM_ON_BAT = "powersupersave";
    RUNTIME_PM_ON_BAT = "auto";
    SOUND_POWER_SAVE_ON_BAT = 1;
    SOUND_POWER_SAVE_CONTROLLER = "Y";
    # USB_AUTOSUSPEND = 1;
    # USB_BLACKLIST = "none";
    # START_CHARGE_THRESH_BAT0 = 40;
    # STOP_CHARGE_THRESH_BAT0 = 80;
  };
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

  programs.adb.enable = true;

  programs.ghidra.package = pkgs.ghidra.withExtensions (exts:
    with exts; [
      gnudisassembler
    ]);
  programs.ghidra.enable = true;
  programs.ghidra.gdb = true;

  services.asusd.enable = true;
  environment.localBinInPath = true;
  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCREEN_SCALE_FACTORS = "2";
    # QT_SCALE_FACTOR = "2"; # Useful for some apps, but multiplies with QT_SCREEN_SCALE_FACTORS for some?
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    CUDNN_PATH = "${pkgs.cudaPackages.cudnn.lib}";
    OPENSSL_DIR = "${pkgs.openssl.dev}";
    OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
    OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
    FONTS = "/run/current-system/sw/share/X11/fonts";
  };
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
    # Nvidia stuff
    cudaPackages.cuda_cudart
    cudaPackages.cudnn
    cudaPackages.libcublas
    cudaPackages.cudatoolkit
    cudaPackages.nsight_systems
  ];
  services.devmon.enable = true; # automount usb to /run/media/saegl/<name>/
  programs.niri.enable = true;

  # NEVER CHANGE
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
