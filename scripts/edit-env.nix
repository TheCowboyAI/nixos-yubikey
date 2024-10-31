{ pkgs }:
pkgs.writeShellScriptBin "get-env" /*bash*/''
  micro /home/yubikey/.env
''
