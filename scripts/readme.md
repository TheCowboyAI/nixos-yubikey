# Install Scripts

Each script appends its activity to LOGFILE: yubikey_setup_$(date +%F).log (this includes NO keys and NO pins)
Each script appends an Event to EVENTLOG: yubikey_setup_$(date +%F).events.json
This is your backup. Every setting we make is saved here to preserve a backup. (this includes all keys and pins)

You can avoid saving this if that is your security practice by setting:

export LOGFILE=/dev/null
export EVENTLOG=/dev/null

or call:

### [set-nolog](set-nolog)
turns off logging

Event: {"logging-set": boolean}

### [set-noevents](set-noevents)
turns off event logging

Event: {"eventlog-set": boolean}

# Getting ready
If you need the .env file, or need to check the status of a yubikey

### [get-env](get-env.nix)
get a copy of a sample .env file

### [get-status](get-status.nix)
get the current status of the yubikey

## Writing to a Yubikey
There is a single all inclusive script to install everything we outlined according to the guide.
You will need to have the environment fully loaded. If it's not, you will get a warning.

### [set-yubikey](set-yubikey.nix)
fully configure a Yubikey
Use this on your first Key

Event: {"yubikey-full-set": boolean}

### [set-backup-key](set-additional-yubikey.nix)
Does everything set-yubikey does, except it just uses the already created keys

Event: {"yubikey-additional-set": boolean}

### [completely-reset-my-yubikey](./completely-reset-my-yubikey.nix)
**WARNING** - this will reset EVERYTHING and kill any keys and pins on the device
This should rarely be used, for devices that need to be wiped and reused.

Event: {"yubikey-full-reset": true} (false if it failed)

### [enable-fido2](enable-fido2.nix)
enable the fido2 module

Event: {"fido2-enabled": boolean}

### [enable-pgp-touch](enable-pgp-touch.nix)
enable the pgp touch module

Event: {"pgp-touch-enabled": boolean}

### [enable-piv-touch](enable-piv-touch.nix)
enable the piv touch module

Event: {"piv-touch-enabled": boolean}

### [make-certkey](make-certkey.nix)
make a new certification key

Event: {"certificate-created": "<name>": {"publickey": <publickey>, "privatekey": <privatekey>}}

### [make-rootca](make-rootca.nix)
make a Root Certificate of Authority (for this Domain)

Event: {"rootca-created": "name": {"publickey": <publickey>, "privatekey": <privatekey>}}

### [make-subkeys](make-subkeys.nix)
make Expiring, Revocable Signing, Authentication, and Encryption Keys based on the Certification Key

Event: 
{"subkeys-created": 
  {"sign": {"publickey": <publickey>, "privatekey": <privatekey>},
   "auth": {"publickey": <publickey>, "privatekey": <privatekey>},
   "encr": {"publickey": <publickey>, "privatekey": <privatekey>}
  }
}

### [make-domain-cert](make-domain-cert.nix)
Make a Domain Certificate based on Root CA

Event: {"domain-cert-created": "name": {"publickey": <publickey>, "privatekey": <privatekey>}}

### [make-tls-client](make-tls-client.nix)
Make a Client Certificate based on Root CA and Domain Certificate

Event: {"tls-client-created": "name": {"publickey": <publickey>, "privatekey": <privatekey>}}

### [random-6](random-6.nix)
returns a random 6 digit code

### [random-8](random-8.nix)
returns a random 8 digit code

### [random-mgmt-key](random-mgmt-key.nix)
returns a random 48 digit code

### [random-pass](random-pass.nix)
returns a random 30 alphanumeric character code

### [set-attributes](set-attributes.nix)
set the ID of the device (user's email)

Event: {"attributes-set": "<identity>"}

### [set-env](set-env.nix)
Set the Environment from .env

Event: {"environment-set": "<path>"}

### [set-fido-pin](set-fido-pin.nix)
set all the Fido Pins

Event: {"fido-pins-set": "FIDO2_PIN"}

### [set-fido-retries](set-fido-retries.nix)
set the number of retries for the fido pin before it locks

Event: {"fido-retries-set": integer}

### [set-pgp-pins](set-pgp-pins.nix)
set all the PGP Pins

Event: {"pgp-pins-set": {"userpin": OPENPGP_USER_PIN, "adminpin": OPENPGP_ADMIN_PIN, "resetcode": OPENPGP_RESET_CODE}}

### [set-pgp-touch](set-pgp-touch.nix)
Activate PGP Touch

Event: {"pgp-touch-set": boolean}

### [set-piv-pin](set-piv-pin.nix)
set all PIV pins

Event: {"piv-pins-set": {"pivpin": PIV_PIN, "pivpuk": PIV_PUK}}

### [verify-xfer](verify-xfer.nix)
verify the keys and certs are on the device and operate as expected

Event: {"xfer-verified": boolean}

### [xfer-cert](xfer-cert.nix)
transfer the certificates from the machine to the yubikey

Event: {"certificates-transferred": boolean}

### [xfer-keys](xfer-keys.nix)
transfer the keys from the machine to the yubikey

Event: {"keys-transferred": boolean}
