{ pkgs }:
pkgs.writeShellScriptBin "enable-pgp-touch" /*bash*/''
  function eventlog(evt) {echo evt >> $EVENTLOG} 

  ykman openpgp keys set-touch dec on
  eventlog "{'encryption-touch-enabled':true}"

  ykman openpgp keys set-touch sig on
  eventlog "{'signature-touch-enabled':true}"
  
  ykman openpgp keys set-touch aut on
  eventlog "{'authetication-touch-enabled':true}"
''
