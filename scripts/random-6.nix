{ pkgs }:
pkgs.writeShellScriptBin "random-6" /*bash*/''
  echo $(LC_ALL=C tr -dc '0-9' < /dev/urandom | fold -w6 | head -1)
''
