{pkgs, ...}: let
  ghidraWithExtensions = pkgs.ghidra.withExtensions (exts:
    with exts; [
      gnudisassembler
    ]);
in {
  config = {
    environment.systemPackages = [
      ghidraWithExtensions
    ];
  };
}
