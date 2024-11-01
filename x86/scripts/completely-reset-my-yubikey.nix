{ pkgs }:
pkgs.writeShellScriptBin "completely-reset-my-yubikey" /*bash*/''
  # are you sure? :-)
  # as this implies, it will kill your yubikey.

    function log {
    local msg="$1"
    echo "$msg" | tee -a "$LOGFILE"
}

      # Reset various YubiKey applets
      echo "Resetting PIV applet..."
      ykman piv reset -f
      log "PIV-applet-reset-completed"

      echo "Resetting FIDO2 applet..."
      ykman fido reset -f
      log "FIDO2-applet-reset-completed"

      echo "Resetting OATH applet..."
      ykman oath reset -f
      log "OATH-applet-reset-completed"

      echo "Resetting OpenPGP applet..."
      ykman openpgp reset -f
      log "Reset-OpenPGP-applet-completed"
      
      echo "Resetting OTP slots..."
      ykman otp delete 1 -f
      ykman otp delete 2 -f
      log "OTP-slots-reset-completed"

      echo "Resetting configuration..."
      ykman config reset -f
      log "config-reset-completed"
''
