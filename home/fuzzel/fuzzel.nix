{pkgs, ...}: {
  home.packages = with pkgs; [
    fuzzel # app launcher + fuzzy finder
    bemoji # emoji
    cliphist # clipboard
    (
      pkgs.writers.writeFishBin "powermenu" {} (builtins.readFile ./powermenu.fish)
    )
  ];
}
