# Initialize Yubikey Set
This is our process for creating Yubikeys in a safe manner.

These instructions are opinionated. For more in-depth understanding of Yubikeys in general, see [Help](./help.md).

Use this nix Flake that will create a bootable usb or sd card to place a machine into a safe, AIR-GAPPED Environment.

The sd card will serve as your backup for this process and to store your private keys in a more useful manner than paper. Logging can be disabled if preferred.

The Environment is very minimal on purpose.

The ONLY purpose to run is to initialize a set of Yubikeys and therefore, it is hardened and anything not required is removed or blocked. This is not a general recovery usb image.

**THESE SHOULD BE NEW, UNUSED YUBIKEYS**
If you reset them, know they could have history you don't want.

## Identity
Identity is the name and email address you will be associating with this key.
There is a primary Identity and for the most part of this guide, we assume you have one email address, or 2 when creating SSL Chain of Authorities. 

Yubikeys are generally considered "personal" devices, but we often use these in an organizational environment. In this case, we use two addresses, if you are just you and not assiciated, just set them to the same email.

Organization Email
Personal Email

### SSL, TLS and CSRs
To support SSL we need some more Identifying Information, like a company, location and domain to apply.

## Keys
We will first create the Certify Key which is never given out.
The Certify Key is NON-REVOCABLE and NON_EXPIRING.

If you destroy this key, you essentially destroy anything the Yubikey is associated with and render it gone forever.

With this in mind, we need keys we can revoke, or rotate without destroying the Yubikey.

The Certify Key generates Subkeys, these Subkeys are what we use to connect with other providers. This way we never have a non-revocable key given to a provider, or used for encryption, signing, or authentication. To rotates keys, we create a two way link to a successor key and then replace the old key.

The Certify Key is going to reside solely on the Yubikeys and the Private Key is not exportable.

Our strategy is to use the Certify Key to generate the proper keys we 
need, these are:

- GPG Certify, Encrypt, Authorize and Sign Keypairs
- SSH Keypair
- SSL/TLS
  - Root CA Certificate
  - x.509 Certificate

We are most likely connecting this to a Password Manager as well that will hold Passkeys and legacy passwords.

We are not restricted to just these, but they are the ones we will create and backup.

All these Keys have distinct importance and we want them all to be different, expiring, and revocable.

This range of certificates and keypairs should handle most operational requirements, but of course yours may vary, you may need more or less of them.

The reason we make TLS certificates is so you may create self-signed certificates you can trust without hassle.
The Root CA provides significant power to make the x.509 Certificate trusted for this device.

If we are linking Yubikeys, we will copy the generated keys to each linked device, so if you have 3 Yubikeys linked, they will all contain ALL the above shared keys.

We can destroy the Private Keys after copying to all devices. This is up to you.  These are Revocable and Expiring keys. They will be replaced at some point. The Certify Key doesn't expire and since it is the root key can just extend itself if it did expire. There are reasons to make it expire, but we won't be doing so.

By linking 3 devices, we should have 3 potentially identical devices to the outside world, but can be identified uniquely as well by serial number.

We only use the Certify Key to further identify the Yubikey, and enable us to use any of these three keys as if they were the same. Yubikey has an open serial number which is unique, but not private. We also want to be able to backup our keys in case of disasters.

The Certify Key has a Public Key as well as an embedded Private Key, which you may back up.

Again, the SSL and GPG Keys can be imported and the Private Keys destroyed. This is up to you to evaluate as a security practice.

We will need several pieces of information as a set of environment variables to be set after boot.

.env is already in .gitignore, but we don't want to store any secrets in git by mistake. So we only edit a copy in the air-gapped environment.  You could also type all this in, but this workflow is about automation.

This is a sufficiently secure process for most cases, it will save you a lot of typing.  If you air-gap, encrypt and put the sd in a safe place, this is good base for you to decide what more or less you may need. If you require a higher level of security, you already know the available options.

### Let's recap what we are doing:

#### Secure environment

Boot into a secure, air-gapped environment.
We are using an off the shelf Dell laptop booting from an sd card in this hardware-configuration.nix. You may need to adjust this before deploying. 

It should have any network wires disconnected, but we turn all networking off anyway.

It should boot and Auto-login as the Yubikey user to:
```bash
/home/yubikey
```
Copy the .env file into the home folder by typing:
```bash
get-env
```
edit the .env file, add your favorite editor to change this
```bash
nano ./.env
```
load the environment
```bash
source ./.env
```
## Environment
To properly set the environment variables, use this guide.

### Logging
We can log everything we do so it is saved for a backup and audit trail.

If you don't want logging,
```bash
export LOGFILE=/dev/null

--OR--

disable-logging
```
Either of these this will turn the logging feature off and none of the PINS or Keys will be persisted outside of the Yubikeys.

This makes you responsible for memorizing or backing them up in some way.

The log file is a convenient way to do this on your sd card, so is the .env file.

Encrypt the sd and put it away in a safe place.
This very safe if you do this in a totally air-gapped environment and use encryption on the drive.

Without encryption, it is world readable, but so is paper, no matter how fancy you are encoding the paper.

These are risks you need to determine. Where will you store the disk encryption key? Maybe the disks are available to all the IT Staff, but only the Supervisor has the keys. These are scenarios for you to decide, not for us to enforce. 

**Our sample scenario is**:
- use new devices
- air-gap
- create an encrypted sd card, write down key
- boot to the sd card
- set yubikeys
- verify yubikeys
- remove sd card
- reboot
- create linked accounts with all yubikeys present
- verify all keys
- test all keys
- put one yubikey and the sd card in safe place
- put encryption key in a different safe place
- use remaining yubikeys

### Identity
This is the Name and Email you are using for this Identity.

This should be a valid email because any certificates your generate will send notices to this address.

Most programs expecting this ID are expecting an email address and that convention is what we recommend.

An email address also must be globally unique, therefore it serves as a unique identifier.

For SSL, we nee some extra information that gets embedded in the certificate.

#### COUNTRY
  2 character code for a Country

#### REGION
  State, Province or similar region

#### LOCALITY
  City, Township, Village, Island, or other locality

#### ORG_NAME
  A Name for the Organization

#### SUB_ORG
  A sub category within the organization, such as a department

#### COMMON_NAME
  What the Certificate will apply to, such as a domain name: www.example.org

#### EMAIL
  Email address associated with this certificate

#### CERT_PASSWORD (optional)
  A password for this certificate, note: while more secure, this may cause unwanted interaction requirements if set.

#### COMPANY (optional)
  A Company Name to associate with this Certificate

### GPG
GnuGPG and PGP are used to create 4 shared secrets for use on multiple Yubikey devices. Once imported, the Private Keys are either locked up or destroyed.

##### The 4 Keys are:
- Certify Key
  - this is your master key and goes nowhere but these yubikeys
- Authentication Key
  - a revocable key for authenticating as a user with your identity
- Signing Key
  - a revocable key for signing with your identity
- Encryption Key
  - a revocable key for encryption.
    - **CAUTION** When this Key is rotated or revoked, anything encrypted with it, will also need to be updated before destroying the old key.
    - For this reason, we recommend freely using this to encrypt live communications, but encrypting files and disks should use a generated key.

### SSH
SSH Keypair is created for Authentication via SSH
Other programs may allow the use of an ssh key for authentication as well, such as git repositories.

### SSL
A Root CA Certificate is created
An X.509 Certificate based on this Root CA is also created for this Identity
This can also be used to create self-signed certificates that are trusted, revokeable and renewable by the Yubikey owner.

## What we need:

Set these environment variables after booting to the secure environment either using the above directions, or manually.

# Additional Information

### Identity
The Name and Email Pair used for this Identity

**IDENTITY**
Format: "Name <email>"
This is the Identity used for GnuPG and is a Name, Email address, Comment triple. The Comments are disabled for compatibility. If you do not use an email address, there may be problems that arise, so just use one.

### Generate GPG Keys
**CERTIFY_PASS**
This is a passphrase used to generate the Certify Key.
It is recommended to be only Uppercase Letters and Numbers.
This should be long:
"I AM AN EXAMPLE PASSPHRASE, THAT CAN BE REMEMBERED EXTENSIVELY - FROM 2024"

There is also a passphrase generator that can be invoked using RANDOM_PASS,
```bash
export CERTIFY_PASS=$RANDOM_PASS
```
If you don't want the random ones, comment them out or don't include them because they do get saved in the log.
This is for backup purposes.

### Subkeys
If rotated, re-encryption may be necessary.

In order to let the world know that your new key pair actually belongs to you without having to meet in person again, the standard procedure is to sign the new key with the old one and the other way around, establishing a hard trust link between them (this action can not be done without access to the old secret key, so as far as anyone can tell, this two-way signature could only have been done by you).

This is the primary reason we backup the Private Keys, existing on the Yubikey is usually sufficient for this, but care must be used during rotation not to lose the old key before the two way link is made.

- Signature Key
  - Key used for PGP Signing
- Encryption Key
  - Key used to encrypt communications, files, and drives.
- Authentication Key
  - Key used for PGP Authentication 

### SSL
- SSL Root CA
  - The Root CA is a certificate used for making self-signed SSL/TLS Certificates that you can trust
- X.509 Certificate
  - A trusted client CA certificate chain to use with client authentication

Both certificates need a block of Identifying information.
Root is usually an Organization
x.509 is an Individual

We use these for internal certificates that we don't need 3rd party certification to use, such as internal development sites or access to a common low security database or web page.

To create a Certificate, we need some additional informationabout the Organization.
If this is a personal Yubikey, you may use anything appropriate, but they re the same fields.

The x.509 Certificate is definitely attached to an Identity.
This is all the same information used in the above certificate, but the Identity is different
in this case, acme@example.org is used, where acme is the automated certificate user and is combined with the root certificate to form a chain.
If you're an individual, this is usually your individual email.

This is NOT a certificate to use, but rather one to generate Certificates you can trust. No one else is necessarily going to trust this, but you can. You certainly could use it, it's perfectly valid, but if it gets burned, you need to replace it on the Yubikey.  Instead, generate new certificates for specific purposes that extend the chain of trust.

If you prefer, you can certainly import an existing Root CA and x.509 you may have purchased. We need something we can ultimately trust ourselves, and also something we fully control.  This Chain of Trust begins at these Yubikeys.  We know anything we generate from them is inside our own chain of trust.

Typically, we use these for development certificates so we have end-to-end encryption without the hassle of going and getting a certificate somewhere.

Organizations will typically put the same Root CA on all Yubikeys and change the x.509 to each person.

## The Yubikeys

**PGP_ADMIN_PIN**
The reset, add keys, configuration pin. 
default value: 12345678

**PGP_USER_PIN**
This pin is for daily Encryption, Signing and Authentication using the GPG Keys we add to these keys
default value: 123456

**PGP_RESET_CODE**
This is generally not used and empty by default.
Its only purpose is to reset the PGP_USER_PIN if Locked.
default value: not set

### PIV - Smartcard Operations
Personal Identity Verification (PIV) is defined in FIPS 201. It is a US government standard defining various authentication and cryptographic operations using a smart card.

**PIV_PIN**
Authentication for Signing and Decryption
default value: 123456

**PIV_PUK**
Unblocks the PIN if locked
default value: 12345678

**PIV_MGMT_KEY**
AES-192 string we set for overwriting the PUK.
default value is 48 chars: 010203040506070801020304050607080102030405060708

***We absolutely want to change these***

### FIDO2
Fido allows us to login to things like Windows with a passwordless interchange.

For Fido we can't share the Key, so when registering Fido2 Keys, you need to register each invividual key.
We suggest doing this last as you will need to swap keys a lot to do this.
Fido2 is just one of several options on the Yubikey, so you are not stuck there.

We want our Yubikey to be as universal as possible, but still remain unique and Fido2 allows for that as well as TOTP.

### TOTP
Timed One Time Passwords are mostly legacy, but we still need to support it for now.

## Conclusion
This is a process we can repeat for many Yubikeys and be confident it is correct and safe to use.

After generating the Keys, repeat the copy process for each Yubikey.

NOTE: Yubikey sets are not clones...
They are "registered" together for certain activities.
Sometimes they have the same Credentials applied to them, but they remain distinct keys.

By generating Sub Keys, we should be able to use these Yubikeys interchangably. We at least can decrypt anything encrypted by these keys and subsequently generated keys.

[Usage on NixOS](./usage.md)
