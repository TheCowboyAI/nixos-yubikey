{ pkgs }:
pkgs.writeShellScriptBin "set-fido-pin" /*bash*/''
  ykman fido access change-pin --new-pin "$FIDO2_PIN"

  echo "{\"fido-access-pin-set\":\"$FIDO2_PIN\"}">>"$LOGFILE"
''
