### **Instructions to Use the Script**

1. **Run the Script**

When rebooting the SD image, it logs in automatically.

   ```bash
   reset-keys
   ```
   The script will guide you through each step, prompting for necessary input and confirmation.

   It does test itself during the reset, to perform more rigorous tests:

   ```bash
   test-keys
   ```
---

### **Script Features**

- **Logging**

  - All actions and outputs are logged to `yubikey_setup.log` for future reference.

- **User Prompts**

  - The script prompts you before performing critical actions, such as resetting the YubiKey.
  - It securely collects sensitive information like PINs without echoing them to the terminal.
  - You may write these pins down, you absolutely will forget them.

- **Automation**

  - Automates the resetting of the YubiKey's OpenPGP and PIV applets.
  - Sets new PINs for OpenPGP, PIV, and FIDO2 applications.
  - Configures touch policies for OpenPGP keys, PIV authentication, and FIDO2 operations.
  - Generates and stores SSH and PGP key pairs.

- **Error Handling**

  - The script exits immediately if a command fails (`set -e`), preventing partial configurations.
  - Provides informative messages to help diagnose any issues.

---

### **Important Notes**

- **Sensitive Data Handling**

  - The script reads PINs and other sensitive data securely using `read -s`.
  - Sensitive information is not printed to the terminal or logged.

- **Manual Steps**

  - **Generating PGP Keys**: The `gpg --card-edit` command for generating PGP keys requires manual interaction due to security reasons. The script pauses and prompts you to follow the on-screen instructions.
  
- **Prerequisites**

  - Ensures all necessary tools are installed (`gpg`, `ykman`, `ssh`, etc.) through the use of the Flake.

- **Backup**

  - Before running the script, it's recommended to backup any existing keys or configurations.
  - This will kill your existing keys.

---

### **Troubleshooting**

- **Commands Not Found**

  - Did you boot from this SD?

- **YubiKey Connection**

  - Make sure your YubiKey is properly connected to your computer before running the script.
  - this may be tested by ... #//todo

- **SSH Agent**

  - The script starts `ssh-agent`.

---

### **Post-Setup Actions**

- **Distribute Public Keys**

  - The script exports your PGP public key to `publickey.asc`. Distribute this key as needed.
  - For SSH authentication, copy the output from `ssh-add -L` to your `authorized_keys` on remote servers.

- **Secure Storage**

  - Keep your new PINs and PUKs in a secure location. Losing them may lock you out of your YubiKey.
  - Optionally create a text file for pins on the SD Device, this will depend on your security policies. 

- **Review Log**

  - After completion, review `yubikey_setup.log` to verify all actions were performed successfully.


# Script Workflow

EACH Step is independent, you can skip any of them.

We process them in a sequence and if prior dependencies are missing, they are skipped.

Setup logging

- Step 1: Reinitialize the Master Key
- Step 2: Set the PINs
- Step 3: Set PIV PINs and PUK
- Step 4: Set the FIDO2 PIN
- Step 5: Enable FIDO2
- Step 6: Setup Touch Response for 2FA
- Step 7: Setting touch policy for PIV Authentication (Slot 9a)...
- Step 8: Setting touch policy for FIDO2 operations...
- Step 9: Store an SSH Private/Public Key Pair
- Step 10: Store a PGP Private/Public Key Pair

close log.

## Notes

2FA and SSH Touch both use "slot 9a", they seem to be mutually exclusive.
You probably want PIV.
SSH is just to touch on ssh, the key is still there and active when plugged in.
not sure how to just generate the key on the device without touch
