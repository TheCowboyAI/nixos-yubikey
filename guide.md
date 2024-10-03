# Initialize Yubikey Set
This is our process for creating Yubikeys in a safe manner.

We want a few things on our Yubikey.

Set PIV
Set OpenSSL Touch

### Subkeys
- Signature Key
- Encryption Key
- Authentication Key
- SSL Root CA

From these 3 we will generate other keys that we actually give out.

These 3 Primary Keys should NOT be use for anything other than creating other keys.
This includes setting the PIV Touch Key...
The PIV Touch Key should be easily revocable and if it's a primary key, you need a new Yubikey.

We have created a nix Flake that will create a bootable usb or sd card to place a machine into a safe, AIR-GAPPED Environment.

The Environment is very minimal on purpose.
The ONLY purpose to run is to initialize a set of Yubikeys and therefore, it is hardened and anything not required is removed or blocked.

This is not a general recovery usb image.

It is purpose driven and activity is ephemeral.

NixOS is Determistic, and I wanted a deterministic process to setup Yubikeys.
This is a process we can repeat for many Yubikeys and be confident it is correct and safe to use.
If you need to setup a single key, this is fine, but a tad complex.
This is intended to be used when setting up many keys for an Organization or Family.

NOTE: Yubikey sets are not clones...
They are "registered" together for certain activities.
Sometimes they have the same Credentials applied to them, but they remain distinct keys.

The intent is that you boot to this flake...
- Follow the instructions provided, or provide a secrets.yaml file.
- When complete: Turn OFF the machine we used.
- unplug the boot device

- reboot into a working environment (not yubikey image, it has no network).
- [Register Accounts with all Providers](https://www.yubico.com/works-with-yubikey/catalog/google-accounts/)
- store the boot device and your backup Yubikey in a safe place.

This provides an audit trail for how the key was made.
It DOES NOT provide any keys inside the Yubikey, those solely reside on the Yubikey.

If you make Secrets you want to manage, store the on the boot device.

Some information, we can set deterministically, in other words, we write it down.
just because I wrote it in a YAML file doesn't make it less secure.

If you are using a Yubikey correctly, you will rarely write to the device.
You WILL however, use it to create many keys, certficates, and use it to login.

Savvy users will store credentials in FIDO and will update the key from time to time. This just means adding and removing credentials, not resetting it.

Usually the Owner of the key can do this.

This IS an appropriate environment in which to do so.
You will always know that this build works with your key. 

If you forgot the keys, sure pull it out and look them up, that is it's purpose.

### Why do we need hardening?

We want an environment as safe as writing a bunch of symbols on a piece of paper and hiding the paper.

Of course paper can't talk to a machine, but you can copy it by taking a picture.

Once you create a PrivateKey on a Yubikey, it ONLY resides there and cannot be copied, cloned, or duplicated in any way.

The PrivateKey can be authenticated, but not copied or exported somewhere.

The reason we harden the system this is created on is that we want to be as certain as reasonable that this Key is not tampered with.

We want a trusted device to run a trusted application to create security keys.

These "master" keys should never be exposed to the internet or any other machine while initializing.

This is what the hardened ISO/SD does. It is a vault where you can safely work on keys. It can be saved with the key in case somehow if it is ever compromised, we have an audit trail of how it was made, including all the running software by exact version.

Alternatively, it may be destroyed and any trace of how the keys were made is gone, providing extreme security.

This is quite literally the key to your Safety Deposit Box where you create other keys.

The Master Key is generally used "once" when creating a Domain. After that, the Master Key is used to link to other revocable keys. 

Your GnuPG master key is also your “identity” among every PGP user. If you loose your master key or if your key is compromised you need to rebuild your identity and reputation from scratch. Instead, if a subkey is compromised, you can revoke the subkey (using your master key) and generate a new subkey.

This can also be our Personal Physical Authenticator.
It can be asked to reply for verification or for two factor authentication.
For any Online Account, or account with rotating keys, we use these subkeys.

This makes human verification very simple in a workflow.

You should not "recycle" Yubikeys, but rotating keys and passwords is pretty common.

If these are corporate devices, destroy them, don't reset them.

If this is a personal device, locking it is more of a personal choice about when you do it. We would recommend locking it when you are certain it is setup the way you need it.

Locking it means having all the PINs set and a Configuration PIN set.

Test and verify everything you want to connect.

If you lose it, destroy it. Don't reset it, revoke the subkeys and make new ones.

## Yubikey capabilities
Currently Yubikey 5 Series is state of the art.

It has the following:
  - Immutable Serial Number
  - PIV
  - OpenPGP
  - FIDO
  - OATH
  - OTP

The Serial Number is world readable...
It's actually written on the outside of most yubikeys.
Don't use it for anything but a PUBLIC identifier.

We will setup several keys, then optionally lock the devices, which will make it useless without the unlock pin.

In general, you SHOULD do this if you worry about the device being destroyed.

If a bad guy gets physical access to your device, they can reset it, thus destroying the keys contained.

This is bad, but usually recoverable if you have a backup. Anyone with physical access can still destroy it with a big enough hammer.

We are more worried about being able to use it for impersonation and want to be able to revoke things quickly.

Low security or even no security is the biggest compromise most people make. If you are going to lock your door, then at least use a dead-bolt, and lock all the windows, and add security cameras to see what is going on. This is the level we are going for.

These may seem like extreme practices, but these are security keys, not really convenience devices. If you want even more immutability, use the Security line of devices over the standard Yubikey. We won't be covering high security here, but somewhere in the "medium" security range.

If you need "High Security", you probably have a team of security experts and these are just elementary guidelines for them.  

In our System, we have the notion of an Organization as well as a Personal Key.

This way, we can create Organization Keys and attach policies to them.

Personal Keys are then issued to individuals with a revocable shared Organizational Key.

This does in fact get pretty complex and the industry changes fairly fast.

We want to generate a lot of One Time Responses from a source we trust, that is the Yubikey.

Using Organizationl+Personal revocable shared keys accomplishes what we are after.

You could make subkeys for all your Providers, that is up to your Security Policy.
We recommend at least two of each with 2 year expirations.

This is not meant to be a comprehensive security analysis of the world, we all have opinions on what is "safe" and what is "extreme".

## Standard settings
We will set these:
  - Certify Key
    - the key you use to generate Subkeys
  - Subkeys
    - Signing
    - Encryption
    - Authentication
  - FIDO
    - WebAuth and Microsoft Hello
    - Credentials
      - Passkeys
      - Username/Passwords
      - API Keys
    - Fingerprints (on bio devices)
  - OATH
    - Web based logins
  - OpenPGP
    - Intended for signing
    - used by git
  - OTP
    - 2FA/MFA
    - The Yubico Authenticator App generates TOTP (Timed One Time passwords) from the Yubikey.
  - PIV
    - Smartcard Operation
    - PIN
    - PUK
    - management key

## SECRETS
Honestly, a text file on an encrypted offline SD device, kept off site in a fireproof safe is usually enough.

We can just change [./x86/disko.nix] and encrypt the disk. Doing this while offline at creation time is "just enough security" for most of us.

If you need more, you know it and will do more.

.secrets.yaml is in .gitignore for a reason.
yes, this is an open file, no it doesn't have to be, but we just said, the disk can be encrypted when needed.

copy [./.secrets.sample.yaml] to ./.secrets.yaml
edit the file to your liking and run
```bash
setup
```
Gathering all these credentials at once, then maintaining them ON the Key as Credentials is a fairly simple process where you just need your pin.

## Generate a Certificate Key
The Certificate Key is your master key.
You want to generate this randomly and store it in an encrypted way.
It will print out on screen once and you need to copy it.

## Subkeys
Generate Signature, Encryption and Authentication Subkeys using the previously configured key type, passphrase and expiration

SSH Keys are a good example, we need a bunch of them in IT and if they are all on my key, then no matter what device I am on, the key can be available.

If you have tons of credentials, then use a Password Manager such as Bitwarden or 1Password and use the Yubikey as the 2FA Device. Usually this only works for web based traffic as it only has triggers in the browser.

We have limited "slots" on the Yubikey to store credentials of different kinds.
We aren't going to save every credential you use here, just high use and highly sensitive ones.

We are not trying to take over what ykman does...
We do want to streamline the process of doing this with a hundred keys.

You will most likely have changes to this process.

### Registration
Registration is the process of activating a device with a provider.

There are many options depending on the provider.

Follow these general guidelines, but remember that to register multiple keys with most providers, you need all the keys available at the same time.

If you are storing the backup key in a safe, you don't want to be pulling it out to update it all the time.

This is why we recommend using SUBKEYS, then any of the devices available in the subkey just work.

### FIDO2
  - PIN (4-63 alpha characters, different than PIV PIN)
  - min length (6 chars)


>If you are being prompted for a FIDO2 PIN and don't know what it is, you will need to reset the YubiKey's FIDO2 function to blank/reset the PIN. Be advised! - this procedure will effectively unregister the key with every account it has been registered with using FIDO U2F or FIDO2, so we strongly recommend taking precautionary measures (see below) prior to resetting.

>If the FIDO2 PIN is entered incorrectly 3 times in a row, the key will need to be reinserted before it will accept additional PIN attempts (reinserting "reboots" the device). If the PIN is entered incorrectly a total of 8 times in a row, the FIDO2 function will become blocked, requiring that it be reset.

This means if it only lives in my head...
Yeah, this kind of thing MUST be a personal decision.

>FIDO2 PINs can be up to 63 alphanumeric characters (in other words, letters and numbers).

Write it on paper, or put it somewhere offline.
You won't be writing anything but pins. A FIDO2 PIN can be 63 characters and most of us can only remember 7... Short term.

FIDO can have several credentials and fingerprints on bio devices.

You should add those after going through this setup, and before you register the devices.

### PIV
Special characters are [supported on the Yubikey](https://docs.yubico.com/yesdk/users-manual/application-piv/pin-puk-mgmt-key.html); don't use them, they aren't WebAuthn compliant.

The Defaults are:
  - PIN: 123456
  - PUK: 12345678
  - management key: 0x010203040506070801020304050607080102030405060708

**AT THE LEAST**, you need to change these.

The rest are up to your usage needs, Bio and NFC only apply to those device.

### OAUTH

Add an account, with the secret key f5up4ub3dw and the name yubico, that requires touch:

```bash
ykman oath accounts add yubico f5up4ub3dw --touch
```

If we find these in secrets.yaml, we add them
  - OAUTH:
    - yubico: # add oauth account named yubico
      - secret: some_secret_passphrase
      - touch: true

### OTP



### SSH

### OpenPGP


