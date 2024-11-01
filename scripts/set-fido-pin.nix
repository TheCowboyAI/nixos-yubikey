{ pkgs }:
pkgs.writeShellScriptBin "set-fido-pin" /*bash*/''
  function eventlog(evt) {echo evt >> $EVENTLOG}

  ykman fido access change-pin --new-pin "$FIDO2_PIN"

  eventlog "{'fido-access-pin-set':'$FIDO2_PIN'}"
''
