{ pkgs }:
pkgs.writeShellScriptBin "set-pgp-pins" ''
  printf "\nAdmin PIN: %12s\nUser PIN: %13s\n\n" "$ADMIN_PIN" "$USER_PIN" | tee -a $LOGFILE
''