  Create NixOS images suitable for initializing YubiKeys.

  This repository builds a bootable NixOS image that includes all of the software you need to initialize a YubiKey, and to configure it for use with GnuPG, SSH, PIV Smartcard, TOTP, TLS, Root CA, x.509 for use with Authentication, Signing and Encryption.

  It is important to note: 
  - This is not ready for an initial release, we are still fixing some things in the scripts.
  - This is not installing anything.
  - It runs from the sd.
  - It leaves nothing behind on the machine used.
  
  We follow recommended security practices by disabling network interfaces and running the configuration environment from an immutable ISO (nix/store is read-only). The only way to write state to persistent storage is by explicit user action.

  This really all depends on how paranoid you want to be.

  Here is the workflow:

  Create an ISO image for Initializing a Yubikey.
  You can get very creative here, but just know this runs on an air-gapped machine the whole time you are configuring the Yubikeys, so intrusion is very unlikely.

  This ISO image is minimal and pulled ONLY from trusted repositories.

  The image has zero ability to either write to the disk (it's mounted read-only except the home folder), nor connect to anything, i.e. ssh, dns, etc. they are all disabled or removed.
  
  Once you disconnect the Yubikeys, They are immutable and have a set of Private Keys that CANNOT be exported.

  This also means that if you lose these keys, you are losing everything these keys produce or unlock.

  We ALWAYS make a pair (or more) of keys.

  One for usage, one for a backup.

  Make more backups if you choose, they all have to be made at the same time. This can get tedious when you have several keys to configure.

  There is NO OPTION to "clone" a Yubikey, it would be pretty useless if you could.

  So in essence, this becomes a physical access device that should be treated like the unique thing it is.

  Put one in a safe location that is fireproof, use the other daily.

  We actually recommend 3 at a minimum, plus using the sd as a backup for all the pins and keys.

  There are all kinds of gymnastics we can do here...

  Just remember, that if you lose them all, you lose everything they unlock.

  Our minimal recommendations, which are actually quite high:

- build the ISO from a trusted machine
- use a NEW usb device and copy the ISO to it.
- using a trusted device:
  - If there is a cable plugged in, unplug it.
  - If you can physically turn off Wifi, do so.
- boot the device onto a fully network disconnected machine (airplane mode... turn all the radios off, which the ISO does.) 

Type
```bash
get-env
```
This will copy a sample .env into home

Edit the .env file and enter your information

By doing this offline, we don't risk it getting put in a git repo.

Enable the environment variables
```bash
source .env
```

Now we can run the embedded script in the ISO to complete our workflow.

If you have a fully filled out and applied .env, we can run:
```bash
set-yubikey-full
```
If you prefer individual steps that this completes at once:
```bash
set-yubikey --help
```
will list the menu of option for writing to the Yubikey

You can run these individually, but it is up to you to complete them.  You also need to do this if you want to skip something, like the x.509 cert, or TOTP.

These scripts are completely open to you in [scripts](./scripts/). These nix file create the commands available.

We are scripting this way because the scripts available to you in this build, become immutable on the sd card, they get baked into the nix store. this way you know that if you boot this sd card in the future, you are getting the exact same bits you should and it's not doing anything unexpect to the Yubikeys and I can inspect everything right here.

no hidden surprises, with the convenience of automation.

```bash
set-yubikey 
```

This is safe to do once, to link additional Yubikeys, we need to run 
```bash
link-yubikey
```
repeat this for each linked device you want to use.
we need to reset some things between copies of the keys
due to the private keys getting replaced by stubs.

Wen you link keys, they are still distinct, they as close to cloning as we can get when we create them as a set.

You cannot do this after the fact and add a new key to a set.

To replace a lost key, you need the remaining keys.
You will rotate the keys, and in the process, add the new keys to a new replacement yubikey.