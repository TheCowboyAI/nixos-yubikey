{ pkgs }:
pkgs.writeShellScriptBin "set-fido-retries" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  ykman fido access set-pin-retries --pin-retries "$FIDO_RETRIES" --uv-retries "$FIDO_RETRIES" --pin "$FIDO2_PIN"
  eventlog "{'fido-pin-retries-set':'$FIDO_RETRIES'}"
''
