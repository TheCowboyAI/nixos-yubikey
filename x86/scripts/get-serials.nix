{ pkgs }:
pkgs.writeShellScriptBin "get-env" /*bash*/''
ykman list --serials
''
