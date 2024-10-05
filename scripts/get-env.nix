{ pkgs }:
pkgs.writeShellScriptBin "get-env" ''
cp ${out}/.env .
''
