{ pkgs }:
pkgs.writeShellScriptBin "help" /*bash*/''
  glow /etc/doc/help.md
''
