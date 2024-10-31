{ pkgs }:
let
  env = pkgs.copyPathToStore ../.env;
in
pkgs.writeShellScriptBin "get-env" /*bash*/''
  cp ${env} /home/yubikey/
''
