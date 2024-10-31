{ pkgs }:
pkgs.writeShellScriptBin "link-yubikey" /*bash*/''
  gpg --card-status
''
