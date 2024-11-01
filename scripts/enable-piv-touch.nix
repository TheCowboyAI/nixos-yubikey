{ pkgs }:
pkgs.writeShellScriptBin "set-piv" /*bash*/''
  function eventlog(evt) {echo evt >> $EVENTLOG}

  ykman piv access set-touch-policy always --management-key default 9a
  eventlog "{'piv-touch-policy-set':'enabled'}"
''
