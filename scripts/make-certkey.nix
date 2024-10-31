{ pkgs }:
# make a key from env vars
pkgs.writeShellScriptBin "make-certkey" /*bash*/''
  gpg --batch --passphrase "$CERTIFY_PASS" \
    --quick-generate-key "$O_IDENTITY" "$KEY_TYPE_AUT" cert never

  # get the revoke cert
    
  KEYID := $(gpg -k --with-colons "$O_IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')

  KEYFP := $(gpg -k --with-colons "$O_IDENTITY" | awk -F: '/^fpr:/ { print $10; exit }')



  certkeyevt = "{"certkey-created":{"publickey":"$KEYID", "fingerprint":"$KEYFP"}}"
  eventlog certkeyevt
''
