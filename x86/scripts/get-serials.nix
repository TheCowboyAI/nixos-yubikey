{ pkgs }:
pkgs.writeShellScriptBin "get-serials" /*bash*/''
ykman list --serials
''
