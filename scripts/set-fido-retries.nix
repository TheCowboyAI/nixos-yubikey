{ pkgs }:
pkgs.writeShellScriptBin "set-fido2-retries" /*bash*/''
  FIDO_RETRIES=8
  ykman fido access set-pin-retries --pin-retries "$FIDO_RETRIES" --uv-retries "$FIDO_RETRIES" --pin "$FIDO2_PIN"
  echo "\"{FIDO2-PIN-retries-set\":\"$FIDO_RETRIES\"}">>"$LOGFILE"
''
