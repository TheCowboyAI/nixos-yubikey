function eventlog {
  local evt="$1"
  echo "$evt" >> "$EVENTLOG"
}

gpg --batch --passphrase "$CERTIFY_PASS" \
  --quick-generate-key "$O_IDENTITY" "$KEY_TYPE_AUT" cert never

# get the revoke cert, probably easier to get them all at once...
# identifying which key they are revoking is what we want to know... this needs further exploration

# public key
KEYID=$(gpg -k --with-colons "$O_IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')

# fingerprint
KEYFP=$(gpg -k --with-colons "$O_IDENTITY" | awk -F: '/^fpr:/ { print $10; exit }')

# make a copy of the key to use for backup yubikeys
gpg --output $GNUPGHOME/$KEYID-certify.pem \
    --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
    --armor --export-secret-keys $KEYID

cp $GNUPGHOME/$KEYID-certify.pem ~

certkeyevt=$( jq -n \
  --arg pubkey "$KEYID" \
  --arg fp "$KEYFP" \
  --arg privkey "$(cat $GNUPGHOME/$KEYID-certify.pem)" \
  "{GpgCertifyKeyCreated: {public-key:$pubkey, private-key: $privkey, fingerprint: $fp}}"
)

eventlog "$certkeyevt"
