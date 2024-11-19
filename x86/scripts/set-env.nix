{ pkgs }:
pkgs.writeShellScriptBin "set-env" /*bash*/''
  source /home/yubikey/.env
  export $CURRENT_STATE
''
