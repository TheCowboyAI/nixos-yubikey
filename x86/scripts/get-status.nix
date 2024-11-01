{ pkgs }:
pkgs.writeShellScriptBin "get-status" /*bash*/''
  gpg --card-status
''
