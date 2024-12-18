## YubiKey Initialization Process

This guide outlines the secure, systematic process for initializing YubiKeys in a controlled environment.

### Secure Environment Setup

Utilize the provided Nix Flake configuration to create a bootable USB or SD card that initializes a secure, **air-gapped** environment. This environment is specifically configured for YubiKey setup and is intentionally minimized for security—only necessary tools are included, and network functions are disabled or removed. The SD card serves as a backup for this process and provides a secure location to store private keys in a more resilient manner than on paper.

> **Important**: This process is intended for new, unused YubiKeys. Resetting a YubiKey can potentially expose prior usage history that may affect security.

---

### Identity Configuration

The identity linked to your YubiKey typically includes your name and email. For most users, one primary email is sufficient, but if creating an SSL Chain of Authorities, you may need two addresses. In organizational settings, you may use both an organizational and a personal email address.

#### SSL, TLS, and CSR Requirements

To support SSL and integrate with PIV functionality, additional identifying information such as organization, location, and domain are necessary.

---

### Key Generation Strategy

We primarily use the ED25519 cryptographic standard, which offers advantages over traditional RSA methods. Our strategy prioritizes creating and securely storing a **Certify Key**. This key is non-revocable and non-expiring, serving as a foundation for generating various subkeys needed for secure communications without risking the loss or exposure of the primary Certify Key.

1. **Certify Key**: The Certify Key remains on the YubiKey, and is non-exportable. It generates all other keys, which can be rotated and revoked without affecting the primary Certify Key.
2. **Generated Keys**:
   - GPG Keypairs: For certification, encryption, authorization, and signing.
   - SSH Keypair: For secure shell access.
   - SSL/TLS Certificates:
     - Root CA: A self-signed certificate for trust validation.
     - X.509 Certificate: For secure, authenticated connections.

Our setup enables multiple YubiKeys (if linked) to contain identical shared keys, with each device identifiable by its unique serial number. This configuration ensures continuity and minimizes data loss risk should a YubiKey be lost or damaged. After copying keys across devices, securely destroy private keys if deemed necessary. However, ensure that keys remain revocable and expirable.

### Required Environmental Variables

Several environment variables must be set before beginning the initialization process. These can be stored in an `.env` file, with sensitive entries marked to prevent accidental upload to Git. Modifying the `.env` file in an air-gapped environment enhances security by avoiding exposure.

---

### Summary of Procedures

1. **Secure the Environment**: Mount the SD card and copy `.env` into `/home/yubikey`.
   - Run the command:
     ```bash
     just copyenv
     ```
2. **Boot** into the air-gapped environment using a bootable SD card.
3. **Automate Setup**: Load the environment variables automatically if `.env` is preloaded.

You can also use commands like `get-env` to retrieve the `.env` file and `set-env` to apply the environment settings.

4. **Run Setup Scripts**: After setting up the environment, proceed with [installation scripts](./scripts/readme.md) as required.

### Logging

Logging can be enabled for an audit trail. 
Logging does not save secure information.
To disable logging for privacy or security reasons:

```bash
export LOGFILE=/dev/null
```

Event-logging can be enabled for an complete audit trail. 
Event-logging DOES store all the pins and keys.
the Eventlog can be tested against the .env file to verify installation.
To disable logging for privacy or security reasons:

```bash
export EVENTLOG=/dev/null
```
Log files can serve as a useful backup. However, ensure they are encrypted if stored on removable media to prevent unauthorized access. 

### Recommended Security Practice

1. Use new devices in an air-gapped environment.
2. Create an encrypted SD card, recording the encryption key securely.
3. Boot from the SD card, configure and verify the YubiKeys, and remove the card after setup.
4. Store one YubiKey and the SD card securely, keeping sd card encryption keys separately.

---

### Details of Configuration

#### Identity

An identity usually comprises your name and email address. We recommend using a valid email, as this serves as a unique identifier. For SSL purposes, additional information such as country, region, locality, and organization name may be required.

#### Key Management and Rotation

**[Key Management Plan](./key-plan.md)**: A KMP is essential for any business today. We have too many keys to manage without one.

**Key Rotation**: Regular key rotation (e.g., every two years) is recommended to comply with standards such as GDPR, HIPAA, and PCI-DSS. Key rotation involves creating a trust link between old and new keys to maintain continuity.

**GPG Keys**:
   - **Certify Key**: The master key, non-expiring.
   - **Authentication Key**: For authenticating with your identity.
   - **Signing Key**: For signing operations.
   - **Encryption Key**: For secure communications and data encryption.

**SSL Keys**:
   - **Root CA**: Self-signed for internal use.
   - **Wildcard Certificate**: For SSL/TLS traffic.
   - **X.509 Client Certificate**: For SSL/TLS traffic.
   - **Other Supplied Keys in /secrets**
     - if we detect additional certificates by following the naming convention of:
       - $COMMON_NAME.<any.valid.domain>.crt and
       - $COMMON_NAME.<any.valid.domain>.key (for the private key)
       - they will be copied into the next available slots
       - for example... a cloudflare origin server cert and a client cert for it...
       - they should be saved into /secrets as:
       - example.com.cf.origin.crt (we don't get a private key)
       - example.com.cf.client.crt
       - example.com.cf.client.key (the private key, for safe keeping, it won't go on the yubikey directly)
       - the name of the crt and the pem must match for this convention.
       - they will go into slots 85 and 86

---

### Device Configuration Parameters

**PGP Administration**:
   - **PGP_ADMIN_PIN**: Used for configuration and reset (default: 12345678).
   - **PGP_USER_PIN**: Daily use PIN for encryption and signing (default: 123456).
   - **PGP_RESET_CODE**: Optional; for resetting the user PIN if needed.

**PIV**:
   - **PIV_PIN**: Used for authentication in PIV applications (default: 123456).
   - **PIV_PUK**: Unblocks the PIV PIN if locked (default: 12345678).
   - **PIV_MGMT_KEY**: A secure AES-192 management key.

**FIDO2**: Enable FIDO2 for passwordless login. Note that FIDO2 keys are unique and must be registered individually.

---

### Final Steps and Usage

This guide provides a secure, repeatable process for initializing YubiKeys in a controlled environment, ensuring that each key is properly configured, backed up, and uniquely identifiable. Repeat key copying steps for each YubiKey, and securely store both the SD card and one YubiKey for redundancy.

For usage information on NixOS, see our [NixOS Usage Guide](./usage.md). 

---

### Summary Checklist

- Initialize the secure environment.
- Set up and verify YubiKeys.
- Establish backups, storing the SD card and one YubiKey in a secure location.
- Link YubiKeys as needed and test all keys for functionality.