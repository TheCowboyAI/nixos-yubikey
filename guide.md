# Initialize Yubikey Set
This is our process for creating Yubikeys in a safe manner.

We have created a nix Flake that will create a bootable usb or sd card to place a machine into a safe, AIR-GAPPED Environment.

The Environment is very minimal on purpose.
The ONLY purpose to run is to initialize a set of Yubikeys and therefore, it is hardened and anything not required is removed or blocked.

This is not a general recovery usb stick.

It is purpose driven and is ephemeral activity.

NixOS is Determistic, and I wanted a deterministic process to setup Yubikeys.
This is a process we can repeat for many Yubikeys and be confident it is correct and safe to use.

NOTE: Yubikey sets are not clones...
They are "registered" together for certain activities.
Sometimes they have the same Credentials applied to them, but they remain distinct keys.

### What we set:
  - PIV (Personal Identity Verification)
    - PIN (personal identification number)
    - PUK (PIN unlock code)
    - management key
  - FIDO (Fast IDentity Online)
    - 

The intent is that you boot this usb...
- Follow the instructions provided, or provide a secrets.yaml file.
- Turn OFF the machine we used.
- unplug the usb.

- reboot into a working environment (not the usb).
- [Register Accounts with all Providers](https://www.yubico.com/works-with-yubikey/catalog/google-accounts/)
- store the usb device and your backup Yubikey in a safe place.

This provides an audit trail for how the key was made.
It DOES NOT provide any keys inside the Yubikey, those solely reside on the Yubikey.
Some information, we can set deterministically, in other words, we write it down.
just because I wrote it in a YAML file doesn't make it less secure.

If you are using a Yubikey correctly, you will rarely write to the device.
You WILL however, use it to create many keys, certficates, and use it to login.

Savvy users will store credentials in FIDO and will update the key from time to time. This just means adding and removing credentials, not resetting it.

Usually the Owner of the key can do this.

### Why do we need hardening?

We want an environment as safe as writing a bunch of symbols on a piece of paper and hiding the paper.

Of course paper can't talk to a machine, but you can copy it by taking a picture.

Once you create a PrivateKey on a Yubikey, it ONLY resides there and cannot be copied, cloned, or duplicated in any way.

The PrivateKey can be authenticated, but not copied or placed in memory somewhere.

The reason we harden the system this is created on is that we want to be as certain as reasonable that this Key is not tampered with.

We want a trusted device to run a trusted application to create security keys.

These "master" keys should never be exposed to the internet or any other machine while initializing.

This is what the hardened ISO/SD does. It is a vault where you can safely work on keys. It can be saved with the key in case somehow if it is ever compromised, we have an audit trail of how it was made, including all the running software by exact version.

Alternatively, it may be destroyed and any trace of how the keys were made is gone, providing extreme security.

This is quite literally the key to your Safety Deposit Box where you create other keys.

The Master Key is generally used "once" when creating a Domain. After that, the Master Key is used to link to other revocable keys. 

Your GnuPG master key is also your “identity” among every PGP user. If you loose your master key or if your key is compromised you need to rebuild your identity and reputation from scratch. Instead, if a subkey is compromised, you can revoke the subkey (using your master key) and generate a new subkey.

For any Online Account, or account with rotating keys, we use these subkeys.

This can also be our Personal Physical Authenticator.
It can be asked to reply for verification or for two factor authentication.

This makes human verification very simple in a workflow.

You should not "recycle" Yubikeys.

If these are corporate devices, destroy them, don't reset them.

If this is a personal device, you may need to reset things, and locking it is more of a personal choice about when you do it. We would recommend locking it when you are certain it is setup the way you need it.

Test and verify everything you want to connect.

Then lock it.

If you lose it, destroy it. Don't reset it.

## Yubikey capabilities
Currently Yubikey 5 Series is state of the art.

It has the following:
  - Immutable Serial Number
  - FIDO
  - OATH
  - OpenPGP
  - OTP
  - PIV

The Serial Number is world readable...
It's actually written on the yubikey.
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

This allows for linked Organizational Keys to replace or rotate Personal Keys.

This does in fact get pretty complex and the industry changes fairly fast.

We want to generate a lot of One Time Responses from a source we trust, that is the Yubikey.

Using Organizationl+Personal revocable shared keys accomplishes what we are after.

This is not meant to be a comprehensive security analysis of the world, we all have opinions on what is "safe" and what is "extreme".

## Standard settings
We will set these:
  - FIDO
    - WebAuth and Microsoft
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

## SECRETS
.secrets.yaml is in .gitignore for a reason.

yes, this is an open file, no it doesn't have to be.

Honestly, a text file on an encrypted offline SD device, kept off site in a fireproof safe is usually enough.

We can just change [./x86/disko.nix] and encrypt the disk. Doing this while offline at creation time is "just enough security" for most of us.

If you need more, you know it and will do more.

Gathering all these credentials at once, then maintaining them ON the Key as Credentials is a fairly simple process where you just need your pin.
SSH Keys are a good example, we need a bunch of them in IT and if they are all on my key, then no matter what device I am on, the key can be available.

If you have tons of credentials, then use a Password Manager such as Bitwarden or 1Password and use the Yubikey as the 2FA Device. Usually this only works for web based traffic as it only has triggers in the browser.

We have limited "slots" on the Yubikey to store credentials of different kinds.
We aren't going to save every credential you use here, just high use and highly sensitive ones.

We are setting PIV last because that locks the device and sets some unchangeable slots.

### FIDO2
>If you are being prompted for a FIDO2 PIN and don't know what it is, you will need to reset the YubiKey's FIDO2 function to blank/reset the PIN. Be advised! - this procedure will effectively unregister the key with every account it has been registered with using FIDO U2F or FIDO2, so we strongly recommend taking precautionary measures (see below) prior to resetting.

>If the FIDO2 PIN is entered incorrectly 3 times in a row, the key will need to be reinserted before it will accept additional PIN attempts (reinserting "reboots" the device). If the PIN is entered incorrectly a total of 8 times in a row, the FIDO2 function will become blocked, requiring that it be reset.

This means if it only lives in my head...
Yeah, this kind of thing MUST be a personal decision.

>FIDO2 PINs can be up to 63 alphanumeric characters (in other words, letters and numbers).

Write it on paper, or put it somewhere offline.
You won't be writing anything but pins. A FIDO2 PIN can be 63 characters and most of us can only remember 7... Short term.

### PIV
Special characters are [supported on the Yubikey](https://docs.yubico.com/yesdk/users-manual/application-piv/pin-puk-mgmt-key.html); don't use them, they aren't WebAuthn compliant.

The Defaults are:
  - PIN: 123456
  - PUK: 12345678
  - management key: 0x010203040506070801020304050607080102030405060708

**AT THE LEAST**, you need to change these.

### OAUTH

### OTP

### SSH

### OpenPGP


