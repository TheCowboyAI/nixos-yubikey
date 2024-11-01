{ pkgs }:
pkgs.writeShellScriptBin "set-fido-pin" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  ykman fido access change-pin --new-pin "$FIDO2_PIN"

  eventlog "{'fido-access-pin-set':'$FIDO2_PIN'}"
''
