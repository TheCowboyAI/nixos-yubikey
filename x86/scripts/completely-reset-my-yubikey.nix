{ pkgs }:
pkgs.writeShellScriptBin "completely-reset-my-yubikey" /*bash*/''
  # are you sure? :-)
  # as this implies, it will kill your yubikey.

  function log {
      local msg="$1"
      echo "$msg" | tee -a "$LOGFILE"
  }

  sn=$(get-serials)
  
  read -p "Do you want to COMPLETELY RESET this Yubikey? serial number: $sn " ok
  if [[ "$ok" = "Y" || "$ok" = "y" ]]; then
    export YUBIKEY_ID="$sn"
  else
    # indicate it failed
    exit 1 
  fi

  # Reset various YubiKey applets
  # there won't be any keys to save, they are all defaults
  # the only thing that will remain the same should be the serial number
  echo "Resetting PIV applet..."
  ykman piv reset -f
  log "PIV-applet-reset-completed: $sn"

  echo "Resetting FIDO2 applet..."
  ykman fido reset -f
  log "FIDO2-applet-reset-completed: $sn"

  echo "Resetting OATH applet..."
  ykman oath reset -f
  log "OATH-applet-reset-completed: $sn"

  echo "Resetting OpenPGP applet..."
  ykman openpgp reset -f
  log "Reset-OpenPGP-applet-completed: $sn"
  
  echo "Resetting OTP slots..."
  ykman otp delete 1 -f
  ykman otp delete 2 -f
  log "OTP-slots-reset-completed: $sn"

  echo "Resetting configuration..."
  ykman config reset -f
  log "config-reset-completed: $sn"

  # test everything is set to defaults
  # test-isDefault
''
