{...}: {
  # Network manager for wifi, conf wifi with `nmtui`
  networking.networkmanager.enable = true;
  networking.hostName = "frostmourne";
  networking.firewall.enable = false;

  networking.interfaces."lo".ipv4.addresses = [
    {
      address = "127.0.0.2";
      prefixLength = 32;
    }
  ];

  networking.stevenblack = {
    enable = false;
    block = ["fakenews" "gambling" "porn" "social"];
  };
}
