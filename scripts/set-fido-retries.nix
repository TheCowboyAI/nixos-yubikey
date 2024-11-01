{ pkgs }:
pkgs.writeShellScriptBin "set-fido2-retries" /*bash*/''
  function eventlog(evt) {echo evt >> $EVENTLOG}

  ykman fido access set-pin-retries --pin-retries "$FIDO_RETRIES" --uv-retries "$FIDO_RETRIES" --pin "$FIDO2_PIN"
  eventlog "{'fido-pin-retries-set':'$FIDO_RETRIES'}"
''
