jkey() {
  jq -r ".\"$1\"" <<< $secrets
}

secrets=$(<"~/secrets.json")
upin="$(jq -r .pgp.user_pin)"
upin_old="$(jq -r .pgp.user_pin_old)"
apin="$(jq -r .pgp.admin_pin)"
apin_old="$(jq -r .pgp.admin_pin_old)"
reset_code="$(jq -r .pgp.reset_code)"

  # Change OpenPGP User PIN
  ykman openpgp access change-pin --pin $upin_old --new-pin "$upin"
  # Change OpenPGP Admin PIN  
  ykman openpgp access change-admin-pin --admin-pin $apin_old --new-admin-pin "$apin"

  # Set OpenPGP Reset Code if provided
  if [ -n "$reset_code" ]; then
    ykman openpgp access set-reset-code --new-reset-code "$reset_code" --admin-pin "$apin"
  fi

  jq -n \
    --arg pin "$upin" \
    --arg admin "$apin" \
    --arg rst "$reset_code" \
    "{PgpPinsSet: {user-pin: $pin, admin-pin: $admin, reset-code: $rst}}" \
  >> $eventlog

xfer-keys

