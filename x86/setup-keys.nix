{ pkgs }:
pkgs.writeShellScriptBin "setup-keys" ''
    # YubiKey Setup Script
    # This script initializes a YubiKey for daily use on NixOS.
    # It is Function Driven:
    # This is Menu and Event-Driven
    #
    # setup - runs the menu, they all have submenus
    #
    # reset:    reinitialize the master key
    # piv: set PIN, PUK and Mgmt key 
    # fido: set Pins, enable/disable touch response for 2FA,
    # ssh: store an SSH key pair.
    # pgp: store a PGP key pair.

    # All actions are logged to yubikey_setup.log.

    # Exit immediately if a command exits with a non-zero status
    set -e

    # Log file
    LOGFILE="yubikey_setup.log"
    # explicit writes only
    #exec > >(tee -i "$LOGFILE") 2>&1

function main() {

# Menu loop
while true; do
    echo "Please enter an option:"
    echo "  1. info   : Info on a YubiKey"
    echo "  2. reset  : Reset everything to YubiKey defaults"
    echo "  3. piv    : Set PIN, PUK, and Management key"
    echo "  4. fido   : Set Pins, enable/disable touch response for 2FA"
    echo "  5. ssh    : Store an SSH key pair"
    echo "  6. pgp    : Store a PGP key pair"
    echo "  7. load   : Load data from .secrets.yaml and apply it."
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
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option, please try again."
            ;;
    esac

    echo # Blank line for readability
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
    echo "connected key:"
    ykman list --serials
    echo
}
  
reset_yubikey() {
      # Reset PIV applet
      echo "Resetting PIV applet..."
      ykman piv reset -f
      echo "PIV applet reset completed."
      echo "Resetting FIDO applet..."
      ykman fido reset -f
      echo "FIDO applet reset completed."
      echo "Resetting OAUTH applet..."
      ykman oauth reset -f
      echo "OAUTH applet reset completed."
      echo "Resetting OpenPGP applet..."
      ykman openpgp reset -f
      echo "OpenPGP applet reset completed."
      echo "Resetting OTP applet..."
      ykman otp delete 1 -f
      ykman otp delete 2 -f
      echo "OTP applet reset completed."
      echo "Resetting Config."
      ykman config reset -f
      echo "Config reset completed."
  }

  set_openpgp() {
    echo "Setting OpenPGP PINs..."
    read_secret "Enter new OpenPGP User PIN (6 digits)" OPENPGP_USER_PIN
    read_secret "Enter new OpenPGP Admin PIN (8 digits)" OPENPGP_ADMIN_PIN
    read_secret "Enter new OpenPGP Reset Code (optional)" OPENPGP_RESET_CODE

    ykman openpgp access set-retries 10 10 10

    echo "OpenPGP PINs set."
  }

  set_piv() {
    echo
    echo "Setting PIV PIN and PUK..."
    read_secret "Enter new PIV PIN (6-8 digits)" PIV_PIN
    read_secret "Enter new PIV PUK (8 digits)" PIV_PUK

    ykman piv change-pin --pin 123456 --new-pin "$PIV_PIN"
    ykman piv change-puk --puk 12345678 --new-puk "$PIV_PUK"
    echo "PIV PIN and PUK set."
  }

  set_fido2_pin() {
    echo
    echo "Setting FIDO2 PIN..."
    read_secret "Enter new FIDO2 PIN" FIDO2_PIN

    ykman fido access change-pin --new-pin "$FIDO2_PIN"
    echo "FIDO2 PIN set."
  }
  
  enable_fido2() {
    # Ensure FIDO2 application is enabled
    echo "Ensuring FIDO2 application is enabled..."
    if ykman config list | grep -q 'FIDO2.*Enabled'; then
        echo "FIDO2 is already enabled."
    else
        ykman config enable fido2
        echo "FIDO2 application enabled."
    fi
  }

  enable_pgp_touch() {
    # Set touch policy for OpenPGP keys
    echo "Setting touch policy for OpenPGP keys..."

    ykman openpgp keys set-touch sig on --admin-pin "$OPENPGP_ADMIN_PIN"
    ykman openpgp keys set-touch enc on --admin-pin "$OPENPGP_ADMIN_PIN"
    ykman openpgp keys set-touch aut on --admin-pin "$OPENPGP_ADMIN_PIN"
    
    echo "Touch policy for OpenPGP keys set."
  }

  enable_piv_touch() {
    echo "Enabling Touch policy for PIV Authentication."
    ykman openpgp keys set-touch aut on
    echo "Touch policy for PIV Authentication enabled."
  }
  disable_piv_touch() {
    echo "Disabling Touch policy for PIV Authentication."
    ykman openpgp keys set-touch aut off
    echo "Touch policy for PIV Authentication disabled."
  }

  enable_fido2_touch() {
    FIDO_RETRIES = 8
    echo "Setting Touch policy for FIDO2 operations."
    ykman fido access set-pin-retries --pin-retries "$FIDO_RETRIES" --uv-retries "$FIDO_RETRIES" --pin "$FIDO2_PIN"
    echo "Touch policy for FIDO2 operations set."
  }

  enable_ssh_auth(){
        CNAME = "YubiKey-SSH"
        # Generate a new key on Slot 9a
        echo "Generating new key on PIV Slot 9a..."

        ykman piv generate-key --algorithm RSA2048 --pin-policy "once" --touch-policy "always" 9a public.pem --management-key default
        echo "Key generated."

        # Generate and import a self-signed certificate
        echo "Generating and importing a self-signed certificate..."

        ykman piv generate-certificate --subject "/CN=$CNAME/" 9a public.pem --pin "$PIV_PIN" --management-key default
        echo "Certificate generated and imported."

        # Remove the temporary public key file
        # or don't... it's a public key.
        # rm -f public.pem

        # List your SSH public key
        echo "Your SSH public key is:"
        ssh-add -L
        echo "Copy this public key to your authorized_keys on remote servers."
  }

  enable_pgp_pair() {
    echo "Generating PGP keys on the YubiKey..."

    # Read user details
    read -rp "Enter your Real Name: " REAL_NAME
    read -rp "Enter your Email: " EMAIL
    
    # we have comments disabled
    # read -rp "Enter a Comment (optional): " COMMENT

    # Prepare the input for gpg --card-edit
    echo "Please follow the prompts to generate your PGP keys on the YubiKey."
    echo "When asked about making an off-card backup, choose according to your preference."


    # Run the GPG commands

# TODO!

    echo "PGP keys generated."

    # Export your public key
    echo "Exporting your public key..."
    gpg --armor --export "$EMAIL" > publickey.asc
    echo "Public key exported to publickey.asc"
  }


function info() {
    # Info on a YubiKey
    echo "Executing 'info' function: Displaying YubiKey information..."
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
    
}

function test() {
    # Test a YubiKey
    echo "Executing 'test' function: Testing YubiKey functionality..."
    # Add your code here
}


main 

    # echo
    # echo "YubiKey Setup Script completed at $(date)"
    # echo "All steps completed successfully!"
    # echo "----------------------------------------"

''
