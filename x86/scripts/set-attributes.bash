    function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  YUBIKEY_ID=$(ykman list --serials)

  gpg --command-fd=0 --pinentry-mode=loopback --edit-card <<EOF
admin
login
$P_IDENTITY
$GPG_PIN
quit
EOF
  
attrevt=$( jq -n \
    --arg sn "$YUBIKEY_ID" \
    --arg id "$P_IDENTITY" \
    "{YubikeyAttributesSet:{yubikey: $sn, identity: $id}}"
)

eventlog "$attrevt"