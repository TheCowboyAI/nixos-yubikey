{ pkgs }:
pkgs.writeShellScriptBin "set-piv-pin" /*bash*/''
  # Change PIV PIN and PUK
  ykman piv change-pin --pin "$DEFAULT_PIN" --new-pin "$PIV_PIN"
  ykman piv change-puk --puk "$DEFAULT_PUK" --new-puk "$PIV_PUK"

  echo "{\"piv-pin-set\":\"$PIV_PIN\", \"piv-puk-set\":\"$PIV_PUK\"}">>"$LOGFILE"
''
