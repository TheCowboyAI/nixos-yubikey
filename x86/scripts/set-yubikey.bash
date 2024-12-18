    # make all the keys first
    # gpg
    make-certkey
    make-subkeys

    # ssl
    make-rootca
    make-domain-cert
    make-tls-client

    # other scripts depend on the $MGMT_KEY
    set-piv-pins

    set-attributes

    set-fido-pin
    set-fido-retries
    set-pgp-pins
    set-oauth-password

    enable-fido
    enable-pgp-touch
    enable-piv-touch

    xfer-certs
    xfer-keys

    setyubikeyevt=$( jq -n \
      --arg id "$P_IDENTITY" \
      --arg sn "$YUBIKEY_ID" \
      "{YubikeySetCompleted: {serial: $sn, identity: $id}}"
    ) 

  eventlog "$setyubikeyevt"

read n 1 -p "Please change Yubikeys and press any key..." ok

done
