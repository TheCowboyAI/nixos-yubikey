{ pkgs }: 
  pkgs.writeShellScriptBin "test-keys" ''
    # Test Script for YubiKey Configuration
    # Run this script to verify that your YubiKey settings are correctly configured.

    # Exit immediately if a command exits with a non-zero status
    set -e

    echo "Starting YubiKey Configuration Tests..."

    # Function to pause and wait for user input
    pause() {
        read -p "Press [Enter] key to continue... Ctrl-C to quit."
    }

    # 1. Test OpenPGP Configuration
    echo "Testing OpenPGP Configuration..."

    # Fetch card status
    if gpg --card-status > /dev/null 2>&1; then
        echo "OpenPGP applet is accessible."
    else
        echo "Error: Cannot access OpenPGP applet."
        exit 1
    fi

    # Test OpenPGP PIN
    echo "Please enter your OpenPGP PIN when prompted."
    if gpg --pinentry-mode loopback --card-status > /dev/null 2>&1; then
        echo "OpenPGP PIN is working."
    else
        echo "Error: OpenPGP PIN is incorrect."
        exit 1
    fi

    pause

    # 2. Test PIV Configuration
    echo "Testing PIV Configuration..."

    # Verify PIV PIN
    echo "Please enter your PIV PIN when prompted."
    if ykman piv info > /dev/null 2>&1; then
        echo "PIV PIN is working."
    else
        echo "Error: PIV PIN is incorrect."
        exit 1
    fi

    pause

    # 3. Test FIDO2 Configuration
    echo "Testing FIDO2 Configuration..."

    # Verify FIDO2 PIN
    echo "Please enter your FIDO2 PIN when prompted."
    if ykman fido info > /dev/null 2>&1; then
        echo "FIDO2 PIN is working."
    else
        echo "Error: FIDO2 PIN is incorrect."
        exit 1
    fi

    pause

    # 4. Test Touch Response for 2FA
    echo "Testing Touch Response for 2FA..."

    echo "You will be prompted to touch your YubiKey."

    # Test touch requirement for OpenPGP signature key
    echo "Testing OpenPGP Signature Key Touch Requirement..."
    echo "Test message" | gpg --clearsign --output /dev/null

    if [ $? -eq 0 ]; then
        echo "Touch response for OpenPGP signature key is working."
    else
        echo "Error: Touch response for OpenPGP signature key failed."
        exit 1
    fi

    pause

    # Test touch requirement for PIV authentication
    echo "Testing PIV Authentication Touch Requirement..."

    # Authenticate using PIV
    if ykman piv authenticate > /dev/null 2>&1; then
        echo "Touch response for PIV authentication is working."
    else
        echo "Error: Touch response for PIV authentication failed."
        exit 1
    fi

    pause

    # 5. Test SSH Key Functionality
    echo "Testing SSH Key Functionality..."

    # Ensure ssh-agent is running
    eval "$(ssh-agent -s)" > /dev/null

    # Remove existing YubiKey SSH keys
    ssh-add -e /usr/lib/libykcs11.so > /dev/null 2>&1 || true

    # Add YubiKey to ssh-agent
    if ssh-add -s /usr/lib/libykcs11.so > /dev/null 2>&1; then
        echo "YubiKey SSH key added to ssh-agent."
    else
        echo "Error: Failed to add YubiKey SSH key to ssh-agent."
        exit 1
    fi

    # List added SSH keys
    if ssh-add -L | grep -q "PIV"; then
        echo "SSH key is recognized by ssh-agent."
    else
        echo "Error: SSH key not recognized by ssh-agent."
        exit 1
    fi

    pause

    # 6. Test PGP Key Functionality
    echo "Testing PGP Key Functionality..."

    # Encrypt and decrypt a test message
    echo "This is a test message." > test_message.txt

    if gpg --encrypt --recipient youremail@example.com test_message.txt > /dev/null 2>&1; then
        echo "PGP encryption is working."
    else
        echo "Error: PGP encryption failed."
        rm -f test_message.txt
        exit 1
    fi

    if gpg --decrypt test_message.txt.gpg > /dev/null 2>&1; then
        echo "PGP decryption is working."
    else
        echo "Error: PGP decryption failed."
        rm -f test_message.txt test_message.txt.gpg
        exit 1
    fi

    # Clean up test files
    rm -f test_message.txt test_message.txt.gpg

    pause

    echo "All tests completed successfully!"

    exit 0
  ''

