{ pkgs }: 
  pkgs.writeShellScriptBin "reset-keys" ''
    # YubiKey Setup Script
    # This script initializes a YubiKey for daily use on NixOS.
    # It will reinitialize the master key, set PINs, set up FIDO2, enable touch response for 2FA,
    # store an SSH key pair, and store a PGP key pair.
    # All actions are logged to yubikey_setup.log.

    # NOTE: This will run on login and is built into configuration.nix

    # Exit immediately if a command exits with a non-zero status
    set -e

    # Log file
    LOGFILE="yubikey_setup.log"
    exec > >(tee -i "$LOGFILE") 2>&1

    echo "YubiKey Setup Script started at $(date)"
    echo "----------------------------------------"

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

    echo
    echo "Step 1: Reinitialize the Master Key"
    echo "WARNING: This will reset your YubiKey's OpenPGP and PIV applets, erasing all data."
    if confirm "Do you want to proceed with resetting the YubiKey?"; then
        # Reset OpenPGP applet
        echo "Resetting OpenPGP applet..."
        echo "This will require confirmation."

        gpg --batch --yes --command-fd 0 --status-fd 1 --no-tty --card-edit <<EOF
    admin
    factory-reset
    yes
    quit
    EOF
        echo "OpenPGP applet reset completed."

        # Reset PIV applet
        echo "Resetting PIV applet..."
        ykman piv reset -f
        echo "PIV applet reset completed."
    else
        echo "YubiKey reset skipped."
    fi

    pause

    echo
    echo "Step 2: Set the PINs"

    # Set OpenPGP PINs
    echo "Setting OpenPGP PINs..."
    read_secret "Enter new OpenPGP User PIN (6 digits)" OPENPGP_USER_PIN
    read_secret "Enter new OpenPGP Admin PIN (8 digits)" OPENPGP_ADMIN_PIN
    read_secret "Enter new OpenPGP Reset Code (optional)" OPENPGP_RESET_CODE

    gpg --batch --yes --command-fd 0 --status-fd 1 --no-tty --card-edit <<EOF
    admin
    passwd
    1
    $OPENPGP_USER_PIN
    $OPENPGP_USER_PIN
    3
    $OPENPGP_ADMIN_PIN
    $OPENPGP_ADMIN_PIN
    4
    $OPENPGP_RESET_CODE
    $OPENPGP_RESET_CODE
    quit
    EOF
    echo "OpenPGP PINs set."

    pause

    # Set PIV PIN and PUK
    echo
    echo "Setting PIV PIN and PUK..."
    read_secret "Enter new PIV PIN (6-8 digits)" PIV_PIN
    read_secret "Enter new PIV PUK (8 digits)" PIV_PUK

    ykman piv change-pin --pin 123456 --new-pin "$PIV_PIN"
    ykman piv change-puk --puk 12345678 --new-puk "$PIV_PUK"
    echo "PIV PIN and PUK set."

    pause

    # Set FIDO2 PIN
    echo
    echo "Setting FIDO2 PIN..."
    read_secret "Enter new FIDO2 PIN" FIDO2_PIN

    ykman fido access change-pin --new-pin "$FIDO2_PIN"
    echo "FIDO2 PIN set."

    pause

    echo
    echo "Step 3: Setup FIDO2"

    # Ensure FIDO2 application is enabled
    echo "Ensuring FIDO2 application is enabled..."
    if ykman config list | grep -q 'FIDO2.*Enabled'; then
        echo "FIDO2 is already enabled."
    else
        ykman config enable fido2
        echo "FIDO2 application enabled."
    fi

    pause

    echo
    echo "Step 4: Setup Touch Response for 2FA"

    # Set touch policy for OpenPGP keys
    echo "Setting touch policy for OpenPGP keys..."

    ykman openpgp keys set-touch sig on --admin-pin "$OPENPGP_ADMIN_PIN"
    ykman openpgp keys set-touch enc on --admin-pin "$OPENPGP_ADMIN_PIN"
    ykman openpgp keys set-touch aut on --admin-pin "$OPENPGP_ADMIN_PIN"
    echo "Touch policy for OpenPGP keys set."

    pause

    # Set touch policy for PIV Authentication (Slot 9a)
    echo
    echo "Setting touch policy for PIV Authentication (Slot 9a)..."

    ykman piv keys set-touch-policy 9a on --management-key default --pin "$PIV_PIN"
    echo "Touch policy for PIV Authentication set."

    pause

    # Set touch policy for FIDO2 operations
    echo
    echo "Setting touch policy for FIDO2 operations..."

    ykman fido access set-pin-retries --pin-retries 8 --uv-retries 8 --pin "$FIDO2_PIN"
    echo "Touch policy for FIDO2 operations set."

    pause

    echo
    echo "Step 5: Store an SSH Private/Public Key Pair"

    # Option 1: Using PIV for SSH Authentication

    if confirm "Do you want to use PIV for SSH authentication?"; then
        # Generate a new key on Slot 9a
        echo "Generating new key on PIV Slot 9a..."

        ykman piv generate-key --algorithm RSA2048 --pin-policy "once" --touch-policy "always" 9a public.pem --management-key default
        echo "Key generated."

        # Generate and import a self-signed certificate
        echo "Generating and importing a self-signed certificate..."

        ykman piv generate-certificate --subject "/CN=YubiKey-SSH/" 9a public.pem --pin "$PIV_PIN" --management-key default
        echo "Certificate generated and imported."

        # Remove the temporary public key file
        rm -f public.pem

        # Configure SSH to use the YubiKey
        echo "Configuring SSH to use the YubiKey..."

        mkdir -p ~/.ssh
        SSH_CONFIG_FILE=~/.ssh/config
        if ! grep -q "PKCS11Provider" "$SSH_CONFIG_FILE"; then
            echo "
    Host *
        PKCS11Provider /usr/lib/libykcs11.so
    " >> "$SSH_CONFIG_FILE"
            echo "SSH configuration updated."
        else
            echo "SSH configuration already contains PKCS11Provider."
        fi

        # Ensure ssh-agent is running
        eval "$(ssh-agent -s)" > /dev/null

        # Add the YubiKey PIV module to ssh-agent
        echo "Adding YubiKey PIV module to ssh-agent..."
        ssh-add -s /usr/lib/libykcs11.so || true
        echo "YubiKey PIV module added to ssh-agent."

        # List your SSH public key
        echo "Your SSH public key is:"
        ssh-add -L
        echo "Copy this public key to your authorized_keys on remote servers."
    else
        echo "Skipping PIV for SSH authentication."
    fi

    pause

    echo
    echo "Step 6: Store a PGP Private/Public Key Pair"

    echo "Generating PGP keys on the YubiKey..."

    # Read user details
    read -rp "Enter your Real Name: " REAL_NAME
    read -rp "Enter your Email: " EMAIL
    read -rp "Enter a Comment (optional): " COMMENT

    # Prepare the input for gpg --card-edit
    echo "Please follow the prompts to generate your PGP keys on the YubiKey."
    echo "When asked about making an off-card backup, choose according to your preference."

    # Run the GPG commands
    gpg --card-edit <<EOF
    admin
    generate
    EOF

    echo "PGP keys generated."

    # Export your public key
    echo "Exporting your public key..."
    gpg --armor --export "$EMAIL" > publickey.asc
    echo "Public key exported to publickey.asc"

    echo
    echo "YubiKey Setup Script completed at $(date)"
    echo "All steps completed successfully!"
    echo "----------------------------------------"
  ''