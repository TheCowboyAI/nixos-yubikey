{ pkgs }:
pkgs.writeShellScriptBin "completely-reset-my-yubikey" ''
# are you sure? :-)
# as this implies, it will kill your yubikey.
    # Reset various YubiKey applets
    echo "Resetting PIV applet..." | tee -a $LOGFILE
    ykman piv reset -f
    echo "PIV applet reset completed." | tee -a $LOGFILE

    echo "Resetting FIDO2 applet..."
    ykman fido reset -f
    echo "FIDO2 applet reset completed." | tee -a $LOGFILE

    echo "Resetting OATH applet..." | tee -a $LOGFILE
    ykman oath reset -f
    echo "OATH applet reset completed." | tee -a $LOGFILE

    echo "Resetting OpenPGP applet..." | tee -a $LOGFILE
    ykman openpgp reset -f
    echo "OpenPGP applet reset completed." | tee -a $LOGFILE

    echo "Resetting OTP slots..." | tee -a $LOGFILE
    ykman otp delete 1 -f
    ykman otp delete 2 -f
    echo "OTP slots reset completed." | tee -a $LOGFILE

    echo "Resetting configuration..." | tee -a $LOGFILE
    ykman config reset -f
    echo "Configuration reset completed." | tee -a $LOGFILE

''
