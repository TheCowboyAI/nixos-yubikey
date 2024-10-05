{ pkgs }:
pkgs.writeShellScriptBin "make-subkeys" ''
# generate Signature, Encryption and Authentication 
# Subkeys using the previously configured env vars
# key type, passphrase and expiration
  
  for SUBKEY in sign encrypt auth ; do \
    gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --quick-add-key "$KEYFP" "$KEY_TYPE" "$SUBKEY" "$EXPIRATION"
  done

# verify keys
  gpg -K | tee -a $LOGFILE

# Save a copy of the Certify key, Subkeys and public key
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
