{ pkgs }:
pkgs.writeShellScriptBin "set-piv" /*bash*/''
  ykman piv access set-touch-policy always --management-key default 9a
  echo "{\"piv-touch-policy-set\":\"enabled\"}">>"$LOGFILE"
''
