jkey() {
  jq -r ".\"$1\"" <<< $secrets
}

secrets=$(<"~/secrets.json")
upin="$(jq -r .pgp.user_pin)"
upin_old="$(jq -r .pgp.user_pin_old)"
apin="$(jq -r .pgp.admin_pin)"
apin_old="$(jq -r .pgp.admin_pin_old)"
reset_code="$(jq -r .pgp.reset_code)"

# a hack to force gpg to see a new yubikey when we swap them
gpg-connect-agent "scd serialno" "learn --force" /bye

    # auth key    
gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
key 1
keytocard
1
$CERTIFY_PASS
$ADMIN_PIN
$savepgpc
EOF

# signing key
gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
key 2
keytocard
2
$CERTIFY_PASS
$ADMIN_PIN
$savepgp
EOF

# encrypt key
gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
key 3
keytocard
3
$CERTIFY_PASS
$ADMIN_PIN
$savepgp
EOF

keysevt=$( jq -n \
  --arg id "$YUBIKEY_ID" \
  --arg key "$KEYID" \
  "{PgpSubkeysTransferred: {yubikey: $id, key: $key}}" 
)

eventlog "$keysevt"
