{ pkgs }:
pkgs.writeShellScriptBin "edit-env" /*bash*/''
  micro /home/yubikey/.env
''
