{ pkgs }:
# make a key from env vars
pkgs.writeShellScriptBin "make-certkey" /*bash*/''
  gpg --batch --passphrase "$CERTIFY_PASS" \
    --quick-generate-key "$IDENTITY" "$KEY_TYPE_AUT" cert never
  
  KEYID := $(gpg -k --with-colons "$IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')

  KEYFP := $(gpg -k --with-colons "$IDENTITY" | awk -F: '/^fpr:/ { print $10; exit }')

  printf "certifykey-created:{\"keyid\": \"%s\", \"keyfp\": \"%s\"}\n" "$KEYID" "$KEYFP" | tee -a $LOGFILE
''
