{ pkgs }:
pkgs.writeShellScriptBin "xfer-keys" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
  }

  # begin a loop for key(s)...
  read -p "How many Yubikeys? \nWe MUST know this to transfer properly,\nenter 1 to 5:" yubikeys
  # we only support 1-5, which you can change as a sanity check
  # currently this may do weird things to the state of gpg-agent if you abort
  if [[yubikeys < 1 || yubikeys > 5]]; then
    exit
  fi

  for (( i=1; i<=yubikeys; i++ )); do
  # exiting on a subsequent yubikey is going to possibly mess up gpg shadow copies, we have to test for that, this is a fairly crude loop
  if ! add-key; then
    exit 1
  fi

  # a hack to force gpg to see a new yubikey when we swap them
  gpg-connect-agent "scd serialno" "learn --force" /bye

        # auth key    
  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 1
  keytocard
  1
  $CERTIFY_PASS
  $ADMIN_PIN
  $(if [[ "$i" == "$yubikeys" ]]; then echo "save"; fi)
  EOF

  # signing key
  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 2
  keytocard
  2
  $CERTIFY_PASS
  $ADMIN_PIN
  $(if [[ "$i" == "$yubikeys" ]]; then echo "save"; fi)
  EOF

  # encrypt key
  gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 3
  keytocard
  3
  $CERTIFY_PASS
  $ADMIN_PIN
  $(if [[ "$i" == "$yubikeys" ]]; then echo "save"; fi)
  EOF

    keysevt=$( jq -n \
      --arg id "$YUBIKEY_ID" \
      --arg key "$KEYID" \
      "{PgpSubkeysTransferred: {yubikey: $id, key: $key}}" 
    )

    eventlog "$keysevt"
  done
''
