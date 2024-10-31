{ pkgs }:
pkgs.writeShellScriptBin "set-pgp-touch" /*bash*/ ''
  ykman openpgp keys set-touch sig on --admin-pin "$OPENPGP_ADMIN_PIN"
  ykman openpgp keys set-touch enc on --admin-pin "$OPENPGP_ADMIN_PIN"
  ykman openpgp keys set-touch aut on --admin-pin "$OPENPGP_ADMIN_PIN"

  echo "{\"OpenPGP-Touch-policy-set\": \"on\"}">>"$LOGFILE"
''
