{ pkgs }:
pkgs.writeShellScriptBin "make-subkeys" /*bash*/''
  # generate Signature, Encryption and Authentication 
  # Subkeys using the previously configured env vars
  # key type, passphrase and expiration
  
  gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
    --quick-add-key "$KEYFP" "$KEY_TYPE_AUTH" auth "$EXPIRATION_Y"

  gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
    --quick-add-key "$KEYFP" "$KEY_TYPE_SIGN" sign "$EXPIRATION_Y"

  gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
    --quick-add-key "$KEYFP" "$KEY_TYPE_ENCR" encrypt "$EXPIRATION_Y"

  # verify keys
  gpg -K | tee -a $LOGFILE

  # Save a copy of the Certify key, Subkeys and Public key
  gpg --output $GNUPGHOME/$KEYID-Certify.key \
      --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --armor --export-secret-keys $KEYID
  cp $GNUPGHOME/$KEYID-Certify.key ~
  echo "Exported $KEYID-Certify" | tee -a $LOGFILE

  gpg --output $GNUPGHOME/$KEYID-Subkeys.key \
      --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --armor --export-secret-subkeys $KEYID
  cp $GNUPGHOME/$KEYID-Subkeys.key ~
  echo "Exported $KEYID-Subkeys" | tee -a $LOGFILE

  gpg --output $GNUPGHOME/$KEYID-$(date +%F).asc \
      --armor --export $KEYID
  cp $GNUPGHOME/$KEYID-$(date +%F).key ~
  echo "Exported $KEYID-$(date +%F)" | tee -a $LOGFILE
''
