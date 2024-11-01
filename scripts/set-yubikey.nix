{ pkgs }:
# Set a single yubikey all at once
# this just calls all the functions we normally use
# DO NOT use this to link Yubikeys
pkgs.writeShellScriptBin "set-yubikey" /*bash*/''
  make-certkey
  make-subkeys
  make-rootca
  make-rootca
  make-tls-client
  set-attributes
  set-pgp-pins
  enable-pgp-touch
  set-piv
  set-totp
  set-oauth

  eventlog "{'yubikey-set-completed': {'identity':'$P_IDENTITY', 'serial':'$YUBIKEY_ID'}}"
''
