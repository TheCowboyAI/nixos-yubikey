{ pkgs }:
pkgs.writeShellScriptBin "enable-pgp-touch" ''
  ykman openpgp keys set-touch dec on
  echo "Enabled Encryption Touch" | tee -a $LOGFILE
  ykman openpgp keys set-touch sig on
  echo "Enabled Signature Touch" | tee -a $LOGFILE
  ykman openpgp keys set-touch aut on
  echo "Enabled Authetication Touch" | tee -a $LOGFILE  
''