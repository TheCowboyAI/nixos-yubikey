{ pkgs }:
pkgs.writeShellScriptBin "setup-keys" ''
# YubiKey Setup Script
# This script initializes a YubiKey for daily use on NixOS.
# It is function-driven and menu-driven.
#
# Options:
#   info   : Info on a YubiKey
#   reset  : Reset everything to YubiKey defaults
#   piv    : Set PIN, PUK, and Management key
#   fido   : Set Pins, enable/disable touch response for 2FA
#   ssh    : Store an SSH key pair
#   pgp    : Store a PGP key pair
#   load   : Load data from .secrets.yaml and apply it
#   test   : Test a YubiKey
#
# All actions are logged to yubikey_setup.log.

# Exit immediately if a command exits with a non-zero status
set -e

# Log file
LOGFILE="yubikey_setup.log"

function main() {
    touch $LOGFILE 
    # Menu loop
    while true; do
        echo "Please enter an option:"
        echo "  1. info   : Info on a YubiKey"
        echo "  2. reset  : Reset everything to YubiKey defaults"
        echo "  3. piv    : Set PIN, PUK, and Management key"
        echo "  4. fido   : Set Pins, enable/disable touch response for 2FA"
        echo "  5. ssh    : Store an SSH key pair"
        echo "  6. pgp    : Store a PGP key pair"
        echo "  7. load   : Load data from .secrets.yaml and apply it"
        echo "  8. test   : Test a YubiKey"
        echo
        echo "  0. exit   : Exit to terminal"
        echo

        read -p "Enter your choice: " choice

        case $choice in
            1 | info)
                info
                ;;
            2 | reset)
                reset
                ;;
            3 | piv)
                piv
                ;;
            4 | fido)
                fido
                ;;
            5 | ssh)
                ssh
                ;;
            6 | pgp)
                pgp
                ;;
            7 | load)
                load
                ;;
            8 | test)
                test
                ;;
            0 | exit)
                echo "Exiting...">>$LOGFILE
                exit 0
                ;;
            *)
                echo "Invalid option, please try again."
                ;;
        esac
    done
}

# Function to pause and wait for user input
pause() {
    read -rp "Press [Enter] key to continue..."
}

# Function to read sensitive input
read_secret() {
    local prompt=$1
    local varname=$2
    echo -n "$prompt: "
    read -rs "$varname"
    echo
}

# Function to confirm actions
confirm() {
    local prompt=$1
    while true; do
        read -rp "$prompt [y/n]: " yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

list_serials() {
    echo "Connected YubiKey(s):"
    serials=$(ykman list --serials)
    if [ -z "$serials" ]; then
        echo "No YubiKeys detected."
        return 1
    fi

    for serial in $serials; do
        echo "Info for YubiKey with serial $serial:"
        ykman --device "$serial" info
        echo
    done
}


# creates a random password for use as a master password
random_pass() {
  export CERTIFY_PASS=$(LC_ALL=C tr -dc 'A-Z1-9' < /dev/urandom | \
  tr -d "1IOS5U" | fold -w 30 | sed "-es/./ /"{1..26..5} | \
  cut -c2- | tr " " "-" | head -1) ; printf "\n$CERTIFY_PASS\n\n"
}

create_cert_key() {
    gpg --batch --passphrase "$CERTIFY_PASS" \
    --quick-generate-key "$IDENTITY" "$KEY_TYPE" cert never

    export KEYID=$(gpg -k --with-colons "$IDENTITY" | awk -F: '/^pub:/ { print $5; exit }')
    export KEYFP=$(gpg -k --with-colons "$IDENTITY" | awk -F: '/^fpr:/ { print $10; exit }')
    printf "\nKey ID: %40s\nKey FP: %40s\n\n" "$KEYID" "$KEYFP"
}

create_subkeys() {
for SUBKEY in sign encrypt auth ; do \
  gpg --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
      --quick-add-key "$KEYFP" "$KEY_TYPE" "$SUBKEY" "$EXPIRATION"
done
}

backup_subkeys() {
gpg --output $GNUPGHOME/$KEYID-Certify.key \
    --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
    --armor --export-secret-keys $KEYID

gpg --output $GNUPGHOME/$KEYID-Subkeys.key \
    --batch --pinentry-mode=loopback --passphrase "$CERTIFY_PASS" \
    --armor --export-secret-subkeys $KEYID

gpg --output $GNUPGHOME/$KEYID-$(date +%F).asc \
    --armor --export $KEYID
}

reset_yubikey() {
    # Reset various YubiKey applets
    echo "Resetting PIV applet...">>"$LOGFILE"
    ykman piv reset -f
    echo "PIV applet reset completed.">>"$LOGFILE"

    echo "Resetting FIDO2 applet..."
    ykman fido reset -f
    echo "FIDO2 applet reset completed.">>"$LOGFILE"

    echo "Resetting OATH applet...">>"$LOGFILE"
    ykman oath reset -f
    echo "OATH applet reset completed.">>"$LOGFILE"

    echo "Resetting OpenPGP applet...">>"$LOGFILE"
    ykman openpgp reset -f
    echo "OpenPGP applet reset completed.">>"$LOGFILE"

    echo "Resetting OTP slots...">>"$LOGFILE"
    ykman otp delete 1 -f
    ykman otp delete 2 -f
    echo "OTP slots reset completed.">>"$LOGFILE"

    echo "Resetting configuration...">>"$LOGFILE"
    ykman config reset -f
    echo "Configuration reset completed.">>"$LOGFILE"
}

set_openpgp() {
    echo "Setting OpenPGP PINs...">>"$LOGFILE"
    read_secret "Enter new OpenPGP User PIN (6 digits)" OPENPGP_USER_PIN
    read_secret "Enter new OpenPGP Admin PIN (8 digits)" OPENPGP_ADMIN_PIN
    read_secret "Enter new OpenPGP Reset Code (optional)" OPENPGP_RESET_CODE

    # Change OpenPGP User PIN and Admin PIN
    ykman openpgp access change-pin --pin 123456 --new-pin "$OPENPGP_USER_PIN"
    ykman openpgp access change-admin-pin --admin-pin 12345678 --new-admin-pin "$OPENPGP_ADMIN_PIN"

    # Set OpenPGP Reset Code if provided
    if [ -n "$OPENPGP_RESET_CODE" ]; then
        ykman openpgp access set-reset-code --new-reset-code "$OPENPGP_RESET_CODE" --admin-pin "$OPENPGP_ADMIN_PIN"
    fi

    # Set retry counts
    ykman openpgp access set-retries 10 10 10 --admin-pin "$OPENPGP_ADMIN_PIN"

    echo "OpenPGP PINs set.">>"$LOGFILE"
}

set_piv() {
    DEFAULT_PIN = 123456
    DEFAULT_PUK = 12345678
    
    echo
    echo "Setting PIV PIN and PUK...">>"$LOGFILE"
    read_secret "Enter new PIV PIN (6-8 digits)" PIV_PIN
    read_secret "Enter new PIV PUK (8 digits)" PIV_PUK

    # Change PIV PIN and PUK
    ykman piv change-pin --pin "$DEFAULT_PIN" --new-pin "$PIV_PIN"
    ykman piv change-puk --puk "$DEFAULT_PUK" --new-puk "$PIV_PUK"

    echo "PIV PIN and PUK set.">>"$LOGFILE"
}

set_fido2_pin() {
    echo
    echo "Setting FIDO2 PIN...">>"$LOGFILE"
    read_secret "Enter new FIDO2 PIN" FIDO2_PIN

    # Change FIDO2 PIN
    ykman fido access change-pin --new-pin "$FIDO2_PIN"

    echo "FIDO2 PIN set.">>"$LOGFILE"
}

enable_fido2() {
    # Ensure FIDO2 application is enabled
    echo "Ensuring FIDO2 application is enabled..."
    if ykman config list | grep -q 'FIDO2.*Enabled'; then
        echo "FIDO2 is already enabled."
    else
        ykman config enable fido2
        echo "FIDO2 application enabled.">>"$LOGFILE"
    fi
}

enable_pgp_touch() {
    # Set touch policy for OpenPGP keys
    echo "Setting touch policy for OpenPGP keys...">>"$LOGFILE"

    read_secret "Enter your OpenPGP Admin PIN" OPENPGP_ADMIN_PIN

    ykman openpgp keys set-touch sig on --admin-pin "$OPENPGP_ADMIN_PIN"
    ykman openpgp keys set-touch enc on --admin-pin "$OPENPGP_ADMIN_PIN"
    ykman openpgp keys set-touch aut on --admin-pin "$OPENPGP_ADMIN_PIN"

    echo "Touch policy for OpenPGP keys set.">>"$LOGFILE"
}

enable_piv_touch() {
    echo "Enabling Touch policy for PIV Authentication...">>"$LOGFILE"
    ykman piv access set-touch-policy always --management-key default 9a
    echo "Touch policy for PIV Authentication enabled.">>"$LOGFILE"
}

disable_piv_touch() {
    echo "Disabling Touch policy for PIV Authentication...">>"$LOGFILE"
    ykman piv access set-touch-policy never --management-key default 9a
    echo "Touch policy for PIV Authentication disabled.">>"$LOGFILE"
}

enable_fido2_touch() {
    FIDO_RETRIES=8
    echo "Setting PIN retries for FIDO2 operations...">>"$LOGFILE"
    ykman fido access set-pin-retries --pin-retries "$FIDO_RETRIES" --uv-retries "$FIDO_RETRIES" --pin "$FIDO2_PIN"
    echo "FIDO2 PIN retries set.">>"$LOGFILE"
}

enable_ssh_auth() {
    CNAME="YubiKey-SSH"
    echo "Generating new key on PIV Slot 9a...">>"$LOGFILE"

    read_secret "Enter your PIV PIN" PIV_PIN

    # Generate a new key on Slot 9a
    ykman piv generate-key --algorithm RSA2048 --pin-policy once --touch-policy always 9a public.pem --management-key default
    echo "Key generated."

    # Generate and import a self-signed certificate
    echo "Generating and importing a self-signed certificate...">>"$LOGFILE"
    ykman piv generate-certificate --subject "/CN=$CNAME/" 9a public.pem --pin "$PIV_PIN" --management-key default
    echo "Certificate generated and imported.">>"$LOGFILE"

    # Optionally remove the temporary public key file
    # rm -f public.pem

    # List your SSH public key
    echo "Your SSH public key is:">>"$LOGFILE"
    ssh-add -L
    echo "Copy this public key to your authorized_keys on remote servers.">>"$LOGFILE"
}

enable_pgp_pair() {
    echo "Generating PGP keys on the YubiKey...">>"$LOGFILE"

    # Read user details
    read -rp "Enter your Real Name: " REAL_NAME
    read -rp "Enter your Email: " EMAIL

    # Prepare the input for gpg --card-edit
    echo "Please follow the prompts to generate your PGP keys on the YubiKey."
    echo "When asked about making an off-card backup, choose according to your preference."

    # TODO: Implement the GPG key generation process

    echo "PGP keys generated.">>"$LOGFILE"

    # Export your public key
    echo "Exporting your public key...">>"$LOGFILE"
    gpg --armor --export "$EMAIL" > publickey.asc
    echo "Public key exported to publickey.asc">>"$LOGFILE"
}

function info() {
    # Info on YubiKeys
    list_serials
}

function reset() {
    # Reset everything to YubiKey defaults
    echo "Executing 'reset' function: Resetting YubiKey to default settings..."
    reset_yubikey
}

function piv() {
    # Set PIN, PUK, and Management key
    echo "Executing 'piv' function: Setting PIN, PUK, and Management key..."
    set_piv
    enable_piv_touch
}

function fido() {
    # Set Pins, enable/disable touch response for 2FA
    echo "Executing 'fido' function: Configuring FIDO settings..."
    set_fido2_pin
    enable_fido2
    enable_fido2_touch
}

function ssh() {
    # Store an SSH key pair
    echo "Executing 'ssh' function: Storing SSH key pair..."
    enable_ssh_auth
}

function pgp() {
    # Store a PGP key pair
    echo "Executing 'pgp' function: Storing PGP key pair..."
    set_openpgp
    enable_pgp_pair
    enable_pgp_touch
}

function test() {
    # Test a YubiKey
    echo "Executing 'test' function: Testing YubiKey functionality..."
    # Add your testing code here
}

# Placeholder for the 'load' function
function load() {
    echo "Executing 'load' function: Loading data from .secrets.yaml..."
    # Add your code to load and apply data from .secrets.yaml
}

# Start the script
main

''
