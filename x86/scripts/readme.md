# Installation Scripts Documentation for YubiKey Setup

Each script appends activities to a log file, `LOGFILE`, named `yubikey_setup_$(date +%F).log`. This log records non-sensitive data, excluding any keys or PINs.

Each script also logs events to `EVENTLOG` with a JSON format named `yubikey_setup_$(date +%F).events.json`, providing a full backup of all configurations, including keys and PINs for continuity and recovery purposes. If your security policy advises against logging, set the following environment variables to disable logging:

```bash
export LOGFILE=/dev/null
export EVENTLOG=/dev/null
```

Or, use the following commands:

- **`set-nolog`**: Disables general logging.
    - Event: `{ "logging-set": false }`
  
- **`set-noevents`**: Disables event logging.
    - Event: `{ "eventlog-set": false }`

### Preparatory Steps

- **`get-env`**: Retrieve a sample `.env` file for configuration purposes.
- **`get-status`**: Check the current status of the YubiKey device.

### YubiKey Configuration

The following scripts enable a comprehensive setup for YubiKey configuration. Ensure that all environment settings are loaded, as incomplete setup will trigger a warning.

- **`set-yubikey`**: Configures a YubiKey for initial setup.
    - Event: `{ "yubikey-full-set": true }`

- **`set-backup-key`**: Configures an additional YubiKey, using the primary key settings.
    - Event: `{ "yubikey-additional-set": true }`

- **`completely-reset-my-yubikey`**: Resets the YubiKey to its default state, removing all keys and PINs. This command should be used only if a full reset is required.
    - Event: `{ "yubikey-full-reset": true }` (returns `false` if reset fails)

### Module Enabling Scripts

These scripts activate additional modules on the YubiKey as required:

- **`enable-fido2`**: Activates the FIDO2 module.
    - Event: `{ "fido2-enabled": true }`
  
- **`enable-pgp-touch`**: Activates the PGP touch feature.
    - Event: `{ "pgp-touch-enabled": true }`
  
- **`enable-piv-touch`**: Activates the PIV touch feature.
    - Event: `{ "piv-touch-enabled": true }`

### Key and Certificate Creation

The following scripts generate and configure cryptographic keys and certificates:

- **`make-certkey`**: Creates a certification key.
    - Event: `{ "certificate-created": { "name": { "publickey": "<publickey>", "privatekey": "<privatekey>" } } }`

- **`make-rootca`**: Creates a root Certificate Authority (CA) for the domain.
    - Event: `{ "rootca-created": { "name": { "publickey": "<publickey>", "privatekey": "<privatekey>" } } }`

- **`make-subkeys`**: Generates expiring, revocable subkeys for signing, authentication, and encryption.
    - Event: `{ "subkeys-created": { "sign": { "publickey": "<publickey>", "privatekey": "<privatekey>" }, "auth": { "publickey": "<publickey>", "privatekey": "<privatekey>" }, "encr": { "publickey": "<publickey>", "privatekey": "<privatekey>" } } }`

- **`make-domain-cert`**: Creates a domain certificate based on the root CA.
    - Event: `{ "domain-cert-created": { "name": { "publickey": "<publickey>", "privatekey": "<privatekey>" } } }`

- **`make-tls-client`**: Generates a TLS client certificate.
    - Event: `{ "tls-client-created": { "name": { "publickey": "<publickey>", "privatekey": "<privatekey>" } } }`

### Random Value Generators

Utilities to generate random codes as required:

- **`random-6`**: Generates a random 6-digit code.
- **`random-8`**: Generates a random 8-digit code.
- **`random-mgmt-key`**: Produces a 48-digit management key.
- **`random-pass`**: Creates a 30-character alphanumeric password.

### Device Attribute and Environment Configuration

- **`set-attributes`**: Sets the device identifier (e.g., user’s email).
    - Event: `{ "attributes-set": "<identity>" }`

- **`set-env`**: Configures the environment variables from a `.env` file.
    - Event: `{ "environment-set": "<path>" }`

### PIN Configuration

The following scripts manage PIN settings for the YubiKey:

- **`set-fido-pin`**: Configures FIDO PINs.
    - Event: `{ "fido-pins-set": "FIDO2_PIN" }`
  
- **`set-fido-retries`**: Sets the allowed retry count for FIDO PINs before locking.
    - Event: `{ "fido-retries-set": integer }`
  
- **`set-pgp-pins`**: Configures PGP PINs for user, admin, and reset codes.
    - Event: `{ "pgp-pins-set": { "userpin": OPENPGP_USER_PIN, "adminpin": OPENPGP_ADMIN_PIN, "resetcode": OPENPGP_RESET_CODE } }`
  
- **`set-piv-pin`**: Configures all PIV PINs.
    - Event: `{ "piv-pins-set": { "pivpin": PIV_PIN, "pivpuk": PIV_PUK } }`

### Verification and Transfer of Keys and Certificates

- **`verify-xfer`**: Verifies the presence and functionality of keys and certificates on the YubiKey.
    - Event: `{ "xfer-verified": true }`

- **`xfer-cert`**: Transfers certificates from the host to the YubiKey.
    - Event: `{ "certificates-transferred": true }`
  
- **`xfer-keys`**: Transfers keys from the host to the YubiKey.
    - Event: `{ "keys-transferred": true }`

These commands and events provide comprehensive setup, configuration, and maintenance capabilities for YubiKey on a NixOS system, offering flexibility for secure logging and backup procedures.