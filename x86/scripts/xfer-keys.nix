{ pkgs }:
pkgs.writeShellScriptBin "xfer-keys" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  # auth key
  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 1
  keytocard
  1
  $CERTIFY_PASS
  $ADMIN_PIN
  save
  EOF
  eventlog "{'openpgp-authkey-transferred':{'keyid':'$KEYID', 'subkey': 1}}"

  # signing key
  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 2
  keytocard
  2
  $CERTIFY_PASS
  $ADMIN_PIN
  save
  EOF
  eventlog "{'openpgp-signkey-transferred':{'keyid':'$KEYID', 'subkey': 2}}"

  # encrypt key
  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 3
  keytocard
  3
  $CERTIFY_PASS
  $ADMIN_PIN
  save
  EOF
  eventlog "{'openpgp-encrkey-transferred':{'keyid':'$KEYID', 'subkey': 3}}"
''
