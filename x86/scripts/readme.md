# Installation Scripts Documentation for YubiKey Setup

Each script appends activities to a log file, `LOGFILE`, named `yubikey_setup_$(date +%F).log`. This log records non-sensitive data, excluding any keys or PINs.

Each script also logs events to `EVENTLOG` with a JSON format named `yubikey_setup_$(date +%F).events.json`, providing a full backup of all configurations, including keys and PINs for continuity and recovery purposes. If your security policy advises against logging, set the following environment variables to disable logging:

You want logging, as it operates a StateMachine.
All these services are Idempotent...
If they have already completed successfully, they don't run again.  

State Transitions are controlled by:
`$CURRENT_STATE` and `$PREV_STATE`
`$CURRENT_STATE` may only transition to one of to states a success or a failure.

The State Graph is:

```mermaid
stateDiagram-v2
    [*] --> make_certkey

    state make_certkey {
        [*] --> Running
        Running --> Completed : $make_certkeyCompleted
        Running --> Failed : $make_certkeyFailed
    }
    make_certkey --> make_subkeys : Completed
    make_certkey --> [*] : Failed

    state make_subkeys {
        [*] --> Running
        Running --> Completed : $make_subkeysCompleted
        Running --> Failed : $make_subkeysFailed
    }
    make_subkeys --> make_rootca : Completed
    make_subkeys --> [*] : Failed

    state make_rootca {
        [*] --> Running
        Running --> Completed : $make_rootcaCompleted
        Running --> Failed : $make_rootcaFailed
    }
    make_rootca --> make_domain_cert : Completed
    make_rootca --> [*] : Failed

    state make_domain_cert {
        [*] --> Running
        Running --> Completed : $make_domain_certCompleted
        Running --> Failed : $make_domain_certFailed
    }
    make_domain_cert --> make_tls_client : Completed
    make_domain_cert --> [*] : Failed

    state make_tls_client {
        [*] --> Running
        Running --> Completed : $make_tls_clientCompleted
        Running --> Failed : $make_tls_clientFailed
    }
    make_tls_client --> set_piv_pins : Completed
    make_tls_client --> [*] : Failed

    state set_piv_pins {
        [*] --> Running
        Running --> Completed : $set_piv_pinsCompleted
        Running --> Failed : $set_piv_pinsFailed
    }
    set_piv_pins --> set_attributes : Completed
    set_piv_pins --> [*] : Failed

    state set_attributes {
        [*] --> Running
        Running --> Completed : $set_attributesCompleted
        Running --> Failed : $set_attributesFailed
    }
    set_attributes --> set_fido_pin : Completed
    set_attributes --> [*] : Failed

    state set_fido_pin {
        [*] --> Running
        Running --> Completed : $set_fido_pinCompleted
        Running --> Failed : $set_fido_pinFailed
    }
    set_fido_pin --> set_fido_retries : Completed
    set_fido_pin --> [*] : Failed

    state set_fido_retries {
        [*] --> Running
        Running --> Completed : $set_fido_retriesCompleted
        Running --> Failed : $set_fido_retriesFailed
    }
    set_fido_retries --> set_pgp_pins : Completed
    set_fido_retries --> [*] : Failed

    state set_pgp_pins {
        [*] --> Running
        Running --> Completed : $set_pgp_pinsCompleted
        Running --> Failed : $set_pgp_pinsFailed
    }
    set_pgp_pins --> set_oauth_password : Completed
    set_pgp_pins --> [*] : Failed

    state set_oauth_password {
        [*] --> Running
        Running --> Completed : $set_oauth_passwordCompleted
        Running --> Failed : $set_oauth_passwordFailed
    }
    set_oauth_password --> enable_fido : Completed
    set_oauth_password --> [*] : Failed

    state enable_fido {
        [*] --> Running
        Running --> Completed : $enable_fidoCompleted
        Running --> Failed : $enable_fidoFailed
    }
    enable_fido --> enable_pgp_touch : Completed
    enable_fido --> [*] : Failed

    state enable_pgp_touch {
        [*] --> Running
        Running --> Completed : $enable_pgp_touchCompleted
        Running --> Failed : $enable_pgp_touchFailed
    }
    enable_pgp_touch --> enable_piv_touch : Completed
    enable_pgp_touch --> [*] : Failed

    state enable_piv_touch {
        [*] --> Running
        Running --> Completed : $enable_piv_touchCompleted
        Running --> Failed : $enable_piv_touchFailed
    }
    enable_piv_touch --> xfer_certs : Completed
    enable_piv_touch --> [*] : Failed

    state xfer_certs {
        [*] --> Running
        Running --> Completed : $xfer_certsCompleted
        Running --> Failed : $xfer_certsFailed
    }
    xfer_certs --> xfer_keys : Completed
    xfer_certs --> [*] : Failed

    state xfer_keys {
        [*] --> Running
        Running --> Completed : $xfer_keysCompleted
        Running --> Failed : $xfer_keysFailed
    }
    xfer_keys --> [*] : Completed
    xfer_keys --> [*] : Failed
```

```bash
export LOGFILE=/dev/null
export EVENTLOG=/dev/null
```

Or, use the following commands:

- **`set-nolog`**: Disables general logging.
    - Event: `{ "logging-set": false }`
  
- **`set-noevents`**: Disables event logging.
    - Event: `{ "eventlog-set": false }`

## Preparatory Steps

- **`get-env`**: Retrieve a sample `.env` file for configuration purposes.
- **`get-status`**: Check the current status of the YubiKey device.

## YubiKey Configuration

The following scripts enable a comprehensive setup for YubiKey configuration. Ensure that all environment settings are loaded, as incomplete setup will trigger a warning.

- **`set-yubikey`**: Configures a YubiKey for initial setup. This will prompt you far a number of keys and whether to add it after displaying the serial number.
    - Event: `{ "yubikey-full-set": true }`

- **`completely-reset-my-yubikey`**: Resets the YubiKey to its default state, removing all keys and PINs. This command should be used only if a full reset is required.
    - Event: `{ "yubikey-full-reset": true }` (returns `false` if reset fails)

## Key and Certificate Creation

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

## Module Enabling Scripts

These scripts activate additional modules on the YubiKey as required:

- **`enable-fido2`**: Activates the FIDO2 module.
    - Event: `{ "fido2-enabled": true }`
  
- **`enable-pgp-touch`**: Activates the PGP touch feature.
    - Event: `{ "pgp-touch-enabled": true }`
  
- **`enable-piv-touch`**: Activates the PIV touch feature.
    - Event: `{ "piv-touch-enabled": true }`

### Verification and Transfer of Keys and Certificates

- **`verify-xfer`**: Verifies the presence and functionality of keys and certificates on the YubiKey.
    - Event: `{ "xfer-verified": true }`

- **`xfer-cert`**: Transfers certificates from the host to the YubiKey.
    - Event: `{ "certificates-transferred": true }`
  
- **`xfer-keys`**: Transfers keys from the host to the YubiKey.
    - Event: `{ "keys-transferred": true }`

These commands and events provide comprehensive setup, configuration, and maintenance capabilities for YubiKey on a NixOS system, offering flexibility for secure logging and backup procedures.