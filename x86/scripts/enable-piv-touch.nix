{ pkgs }:
pkgs.writeShellScriptBin "enable-piv-touch" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  ykman piv access set-touch-policy always --management-key default 9a
  eventlog "{'piv-touch-policy-set':'enabled'}"
''
