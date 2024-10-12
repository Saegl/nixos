{...}: {
  # Network manager for wifi, conf wifi with `nmtui`
  networking.networkmanager.enable = true;
  networking.hostName = "frostmourne";
  networking.firewall.enable = false;

  networking.stevenblack = {
    enable = false;
    block = ["fakenews" "gambling" "porn" "social"];
  };
}
