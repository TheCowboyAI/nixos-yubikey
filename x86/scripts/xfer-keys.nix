{ pkgs }:
pkgs.writeShellScriptBin "xfer-keys" /*bash*/''
    function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  }

    # begin a loop for backup keys...
    read -p "How many Yubikeys? \nWe MUST know this to transfer properly,\nenter 1 to 5:" yubikeys
    # we only support 1-5, which you can change as a sanity check
    if [[yubikeys < 1 || yubikeys > 5]]; then
      exit
    fi

    for (( i=1; i<=yubikeys; i++ )); do
      # get the current serial
      YUBIKEY_ID=(ykman list --serials)
      gpg-connect-agent "scd serialno" "learn --force" /bye

      # exiting on a subsequent yubikey is going to possibly mess up gpg shadow copies, we have to test for that, this is a fairly crude loop
      read -p "Do you want to transfer keys to this Yubikey?: $YUBIKEY_ID" ok
      # we only support 1-5, which you can change as a sanity check
      if [[ "$ok" != "Y" && "$ok" != "y" ]]; then
        exit
      fi

      eventlog "{'yubikey-added':{'yubikey':'$YUBIKEY_ID'}}"

      # auth key
    
      gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 1
  keytocard
  1
  $CERTIFY_PASS
  $ADMIN_PIN
  $(if [[ "$i" == "$yubikeys" ]]; then echo "save"; fi)
  EOF

      eventlog "{'openpgp-authkey-transferred':{'yubikey':'$YUBIKEY_ID', 'keyid':'$KEYID', 'subkey': 1}}"

      # signing key
      gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 2
  keytocard
  2
  $CERTIFY_PASS
  $ADMIN_PIN
  $(if [[ "$i" == "$yubikeys" ]]; then echo "save"; fi)
  EOF

      eventlog "{'openpgp-signkey-transferred':{'yubikey':'$YUBIKEY_ID', 'keyid':'$KEYID', 'subkey': 2}}"

      # encrypt key
      gpg --command-fd=0 --pinentry-mode=loopback --edit-key $KEYID <<EOF
  key 3
  keytocard
  3
  $CERTIFY_PASS
  $ADMIN_PIN
  $(if [[ "$i" == "$yubikeys" ]]; then echo "save"; fi)
  EOF

      eventlog "{'openpgp-encrkey-transferred':{'yubikey':'$YUBIKEY_ID', 'keyid':'$KEYID', 'subkey': 3}}"
    done
''
