{ pkgs }:
# make a key from env vars
pkgs.writeShellScriptBin "make-certkey" ''
  gpg --batch --passphrase "$CERTIFY_PASS" \
    --quick-generate-key "$IDENTITY" "$KEY_TYPE" cert never
  
  KEYID := $(gpg -k --with-colons "$IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')

  KEYFP := $(gpg -k --with-colons "$IDENTITY" | awk -F: '/^fpr:/ { print $10; exit }')

  printf "\nKey ID: %40s\nKey FP: %40s\n\n" "$KEYID" "$KEYFP" | tee -a $LOGFILE
''
