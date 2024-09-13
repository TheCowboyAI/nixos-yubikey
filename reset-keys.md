### **Instructions to Use the Script**

1. **Run the Script**

When rebooting the ISO image, it shouud start automatically.

to run manually:

   ```bash
   ./reset-keys.sh
   ```
   The script will guide you through each step, prompting for necessary input and confirmation.

---

### **Script Features**

- **Logging**

  - All actions and outputs are logged to `yubikey_setup.log` for future reference.

- **User Prompts**

  - The script prompts you before performing critical actions, such as resetting the YubiKey.
  - It securely collects sensitive information like PINs without echoing them to the terminal.

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

  - Ensure all necessary tools are installed (`gpg`, `ykman`, `ssh`, etc.).
  - The script assumes default locations for libraries (e.g., `/usr/lib/libykcs11.so`). Adjust paths if they differ on your system.

- **Backup**

  - Before running the script, it's recommended to backup any existing keys or configurations.

---

### **Troubleshooting**

- **Commands Not Found**

  - If any commands like `ykman` or `gpg` are not found, ensure they are installed and included in your `PATH`.

- **Permission Issues**

  - If you encounter permission errors, ensure your user has the necessary permissions or run the script with appropriate privileges.

- **YubiKey Connection**

  - Make sure your YubiKey is properly connected to your computer before running the script.

- **SSH Agent**

  - The script starts `ssh-agent` if it's not already running. Ensure that `ssh-agent` is available on your system.

---

### **Post-Setup Actions**

- **Distribute Public Keys**

  - The script exports your PGP public key to `publickey.asc`. Distribute this key as needed.
  - For SSH authentication, copy the output from `ssh-add -L` to your `authorized_keys` on remote servers.

- **Secure Storage**

  - Keep your new PINs and PUKs in a secure location. Losing them may lock you out of your YubiKey.

- **Review Log**

  - After completion, review `yubikey_setup.log` to verify all actions were performed successfully.
