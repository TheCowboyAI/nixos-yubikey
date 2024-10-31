{ pkgs }:
pkgs.writeShellScriptBin "random-8" /*bash*/''
  echo $(LC_ALL=C tr -dc '0-9' < /dev/urandom | fold -w8 | head -1)
''
