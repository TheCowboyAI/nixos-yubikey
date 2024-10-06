{ pkgs }:
let
  env = pkgs.copyPathToStore ../x86/.env;
in
pkgs.writeShellScriptBin "get-env" ''
    cp ${env} /home/yubikey
''
