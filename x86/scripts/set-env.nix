{ pkgs }:
pkgs.writeShellScriptBin "get-env" /*bash*/''
  source /home/yubikey/.env
''
