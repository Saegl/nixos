{...}: {
  # Network manager for wifi, conf wifi with `nmtui`
  networking.networkmanager.enable = true;
  networking.hostName = "frostmourne";
  networking.firewall.enable = false;
}
