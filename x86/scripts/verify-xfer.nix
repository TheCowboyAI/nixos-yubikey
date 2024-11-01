{ pkgs }:
pkgs.writeShellScriptBin "verify-xfer" /*bash*/''
  gpg -K
''
