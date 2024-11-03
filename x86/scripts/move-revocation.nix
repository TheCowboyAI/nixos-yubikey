{ pkgs }:
pkgs.writeShellScriptBin "move-revocation" /*bash*/''
    function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  }

  # we are collecting everything into the eventlog as well as the home forlder for easy retrieval
  # copy ALL the revocation certificates from /home/yubikey/.gnupg/openpgp-revocs.d
  cp /home/yubikey/.gnupg/openpgp-revocs.d/* /home/yubikey

''
