{ pkgs }:
# Set a single yubikey all at once
# this just calls all the functions we normally use
# DO NOT use this to link Yubikeys
pkgs.writeShellScriptBin "set-yubikey" /*bash*/''
  sn=$(get-serials)
  read -p "Do you want to add this Yubikey?: $YUBIKEY_ID" ok
  if [[ "$ok" != "Y" && "$ok" != "y" ]]; then
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

  eventlog "{'yubikey-set-completed': {'identity':'$P_IDENTITY', 'serial':'$YUBIKEY_ID'}}"
''
