function eventlog {
  local evt="$1"
  echo "$evt" >> "$EVENTLOG"
}

ykman fido access change-pin --new-pin "$FIDO2_PIN"

fidoevt=$( jq -n \
    --arg pin "$FIDO2_PIN" \
    "{FidoAccessPinSet: {fido-pin: $pin}}"
  )
eventlog $fidoevt