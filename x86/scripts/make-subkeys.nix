{ pkgs }:
pkgs.writeShellScriptBin "make-subkeys" /*bash*/''
    # generate Signature, Encryption and Authentication 
    # Subkeys using the previously configured env vars
    # key type, passphrase and expiration
  
    function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  }

    gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --quick-add-key "$KEYFP" "$KEY_TYPE_AUTH" auth "$EXPIRATION_Y"

    gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --quick-add-key "$KEYFP" "$KEY_TYPE_SIGN" sign "$EXPIRATION_Y"

    gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --quick-add-key "$KEYFP" "$KEY_TYPE_ENCR" encrypt "$EXPIRATION_Y"

    # Save a copy of the Certify key, Subkeys and Public key
    # we use these to copy to backup yubikeys 
    gpg --output $GNUPGHOME/$KEYID-subkeys.pem \
        --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
        --armor --export-secret-subkeys $KEYID

    cp $GNUPGHOME/$KEYID-subkeys.pem ~

    gpg --output $GNUPGHOME/$KEYID-$(date +%F).pub \
        --armor --export $KEYID

    cp $GNUPGHOME/$KEYID-$(date +%F).pub ~

    subkeyevt=$( jq -n \
      --arg keyid "$KEYID" \
      --arg pubkey $(cat $GNUPGHOME/$KEYID-$(date +%F).pub) \
      --arg subkeys "$(jc $(cat $GNUPGHOME/$KEYID-subkeys.pem))" \ 
      "{GpgSubkeysCreated: {keyid: $keyid, public-key: $key, subkeys: $subkeys}}"
    )
    
    eventlog "$subkeyevt"
''
