{ pkgs }:
pkgs.writeShellScriptBin "enable-pgp-touch" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
} 

  ykman openpgp keys set-touch dec on
  eventlog "{'pgp-encryption-touch-enabled':true}"

  ykman openpgp keys set-touch sig on
  eventlog "{'pgp-signature-touch-enabled':true}"
  
  ykman openpgp keys set-touch aut on
  eventlog "{'pgp-authetication-touch-enabled':true}"
''
