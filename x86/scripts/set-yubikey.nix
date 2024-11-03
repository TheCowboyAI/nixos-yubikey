{ pkgs }:
# Set a single yubikey all at once
# this just calls all the functions we normally use
# DO NOT use this to link Yubikeys
pkgs.writeShellScriptBin "set-yubikey" /*bash*/''
    # Add Current Yubikey
    if !(add-key)
      exit
    fi

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

    enable-fido2
    enable-pgp-touch
    enable-piv-touch

    xfer-certs
    xfer-keys

    setyubikeyevt=$( jq -n \
      --arg id "$P_IDENTITY" \
      --arg sn "$YUBIKEYS" \
      "{YubikeySetCompleted: {identity: $id, serials: $sn}}"
    ) 

  eventlog "$setyubikeyevt"
''
