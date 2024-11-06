function eventlog {
  local evt="$1"
  echo "$evt" >> "$EVENTLOG"
}

ykman fido access set-pin-retries --pin-retries "$FIDO_RETRIES" --uv-retries "$FIDO_RETRIES" --pin "$FIDO2_PIN"

fidoevt=$( jq -n \
  --arg retries "$FIDO2_RETRIES" \
  "{FidoPinRetriesSet: {fido-retries: $retries}}"
)
eventlog $fidoevt