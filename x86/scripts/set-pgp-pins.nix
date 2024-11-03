{ pkgs }:
pkgs.writeShellScriptBin "set-pgp-pins" /*bash*/''
    function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  }

  # Change OpenPGP User PIN
  ykman openpgp access change-pin --pin $OPENPGP_USER_PIN_OLD --new-pin "$OPENPGP_USER_PIN"
  # Change OpenPGP Admin PIN  
  ykman openpgp access change-admin-pin --admin-pin $OPENPGP_ADMIN_PIN_OLD --new-admin-pin "$OPENPGP_ADMIN_PIN"

  # Set OpenPGP Reset Code if provided
  if [ -n "$OPENPGP_RESET_CODE" ]; then
    ykman openpgp access set-reset-code --new-reset-code "$OPENPGP_RESET_CODE" --admin-pin "$OPENPGP_ADMIN_PIN"
  fi

  pgpevt=$( jq -n \
    --arg upin "$OPENPGP_USER_PIN" \
    --arg apin "$OPENPGP_ADMIN_PIN" \
    --arg rst "$OPENPGP_RESET_CODE" \
    "{PgpPinsSet: {user-pin: $upin, admin-pin: $apin, reset-code: $rst}}"
  )
  eventlog "$pgpevt"
''
