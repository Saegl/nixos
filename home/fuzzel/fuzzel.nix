{pkgs, ...}: {
  home.packages = with pkgs; [
    fuzzel # app launcher + fuzzy finder
    bemoji # emoji
    (
      pkgs.writers.writeFishBin "powermenu" {} (builtins.readFile ./powermenu.fish)
    )
  ];
}
