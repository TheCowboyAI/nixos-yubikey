  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
} 

local enabled="on"

ykman openpgp keys set-touch dec $enabled
ykman openpgp keys set-touch sig $enabled
ykman openpgp keys set-touch aut $enabled

pgpauthevt=$( jq -n \
  -- arg encr "$enabled" \
  -- arg sign "$enabled" \
  -- arg auth "$enabled" \
  "{PgpTouchPolicySet: {encryption-touch: $encr, signature-touch $sign, authentication-touch: $auth}}"
)
eventlog "$pgpauthevt"