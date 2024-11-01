{ pkgs }:
# make a key from env vars
pkgs.writeShellScriptBin "make-certkey" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  gpg --batch --passphrase "$CERTIFY_PASS" \
    --quick-generate-key "$O_IDENTITY" "$KEY_TYPE_AUT" cert never

  # get the revoke cert

  export $KEYID = $(gpg -k --with-colons "$O_IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')

  export $KEYFP = $(gpg -k --with-colons "$O_IDENTITY" | awk -F: '/^fpr:/ { print $10; exit }')

  # make a copy of the key to use for backup yubikeys
  gpg --output $GNUPGHOME/$KEYID-certify.pem \
      --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --armor --export-secret-keys $KEYID
  cp $GNUPGHOME/$KEYID-certify.pem ~

  certkeyevt = "{'certify-key-created':{'publickey':'$KEYID', 'fingerprint':'$KEYFP', 'privatekey':'(cat $GNUPGHOME/$KEYID-certify.pem)'}}"
  eventlog certkeyevt
''
