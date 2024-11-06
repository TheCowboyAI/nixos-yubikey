function eventlog {
local evt="$1"
echo "$evt" >> "$EVENTLOG"
}

# begin a loop for key(s)...
savepgp=""
# exiting on a subsequent yubikey is going to possibly mess up gpg shadow copies, we have to test for that, this is a fairly crude loop
echo "Will this be the last key?"
read -n1 lastkey

# we only support 1-5, which you can change as a sanity check
# currently this may do weird things to the state of gpg-agent if you abort
savepgp=$([[ "$lastkey" == "Y" || "$lastkey" == "y" ]] && echo "save" || echo "")

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
