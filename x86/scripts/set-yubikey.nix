{ pkgs }:
# Set a single yubikey all at once
# this just calls all the functions we normally use
# DO NOT use this to link Yubikeys
pkgs.writeShellScriptBin "set-yubikey" /*bash*/''
  get-serials
  # continue?
  set-attributes

  make-certkey
  make-subkeys

  make-rootca
  make-domain-cert
  make-tls-client

  set-fido-pin
  set-fido-retries
  set-pgp-pins
  set-piv-pins
  set-oauth-password

  enable-fido2
  enable-pgp-touch
  enable-piv-touch

  eventlog "{'yubikey-set-completed': {'identity':'$P_IDENTITY', 'serial':'$YUBIKEY_ID'}}"
''
