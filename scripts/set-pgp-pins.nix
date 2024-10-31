{ pkgs }:
pkgs.writeShellScriptBin "set-pgp-pins" /*bash*/''
  # Change OpenPGP User PIN and Admin PIN
  ykman openpgp access change-pin --pin $OPENPGP_USER_PIN_OLD --new-pin "$OPENPGP_USER_PIN"
  ykman openpgp access change-admin-pin --admin-pin $OPENPGP_ADMIN_PIN_OLD --new-admin-pin "$OPENPGP_ADMIN_PIN"

  # Set OpenPGP Reset Code if provided
  if [ -n "$OPENPGP_RESET_CODE" ]; then
      ykman openpgp access set-reset-code --new-reset-code "$OPENPGP_RESET_CODE" --admin-pin "$OPENPGP_ADMIN_PIN"
  fi

  echo "{\"openpgp-access-code-reset\":\"$OPENPGP_RESET_CODE\"}">>"$LOGFILE"
''
