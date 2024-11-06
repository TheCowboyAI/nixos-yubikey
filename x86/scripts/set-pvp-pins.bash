  function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  }

  # Change PIV PIN and PUK
  ykman piv change-pin --pin "$DEFAULT_PIN" --new-pin "$PIV_PIN"
  ykman piv change-puk --puk "$DEFAULT_PUK" --new-puk "$PIV_PUK"
  ykman piv change-management-key --algorithm $PIV_ALG --management-key $MGMT_KEY_OLD -new-management-key $MGMT_KEY 

  pivevt=$( jq -n \
    --arg upin "$PIV_PIN" \
    --arg apin "$PIV_PUK" \
    --arg rst "$MGMT_KEY" \
    "{PivPinsSet: {pin: $upin, puk: $apin, management-key: $rst}}"
  )
  eventlog "$pivevt"