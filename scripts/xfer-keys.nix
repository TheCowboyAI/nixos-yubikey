{ pkgs }:
pkgs.writeShellScriptBin "xfer-keys" /*bash*/''
  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 1
  keytocard
  1
  $CERTIFY_PASS
  $ADMIN_PIN
  save
  EOF

  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 2
  keytocard
  2
  $CERTIFY_PASS
  $ADMIN_PIN
  save
  EOF

  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 3
  keytocard
  3
  $CERTIFY_PASS
  $ADMIN_PIN
  save
  EOF
''
