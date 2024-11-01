{ pkgs }:
# Set a single yubikey all at once
# this just calls all the functions we normally use
# DO NOT use this to link Yubikeys
pkgs.writeShellScriptBin "set-backup-key" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  xfer-keys
  xfer-cert

  set-fido-pin
  set-fido-retries
  enable-fido2

  set-pgp-pins
  enable-pgp-touch

  set-piv-pins

  eventlog "{'backup-key-set': {'identity':'$P_IDENTITY', 'serial':'$YUBIKEY_ID'}}"
''
