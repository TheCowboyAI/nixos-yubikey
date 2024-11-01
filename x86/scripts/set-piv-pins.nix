{ pkgs }:
pkgs.writeShellScriptBin "set-piv-pins" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  # Change PIV PIN and PUK
  ykman piv change-pin --pin "$DEFAULT_PIN" --new-pin "$PIV_PIN"
  ykman piv change-puk --puk "$DEFAULT_PUK" --new-puk "$PIV_PUK"

  eventlog "{'piv-pin-set':'$PIV_PIN', 'piv-puk-set':'$PIV_PUK'}"
''
