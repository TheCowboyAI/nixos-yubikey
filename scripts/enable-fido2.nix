{ pkgs }:
let
in
pkgs.writeShellScriptBin "enable-fido2" /*bash*/''
  function log(msg) {echo msg >> $LOGFILE} 

  if !(ykman config list | grep -q 'FIDO2.*Enabled'); then
      ykman config enable fido2
      log "FIDO2-enabled"
  fi
''
