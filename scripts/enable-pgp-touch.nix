{ pkgs }:
pkgs.writeShellScriptBin "enable-pgp-touch" /*bash*/''
  function log(msg) {echo msg | tee -a $LOGFILE} 

  ykman openpgp keys set-touch dec on
  log "encryption-touch-enabled"

  ykman openpgp keys set-touch sig on
  log "signature-touch-enabled"
  
  ykman openpgp keys set-touch aut on
  log "authetication-touch-enabled"  
''
