{ pkgs }:
# Set a single yubikey all at once
# this just calls all the functions we normally use
# DO NOT use this to link Yubikeys
pkgs.writeShellScriptBin "set-yubikey" /*bash*/''
  set-attributes
  make-certkey
  make-subkeys
  make-rootca
  make-x509
  set-pgp-pins
  enable-pgp-touch
  set-piv
  set-totp
  set-oauth
''
