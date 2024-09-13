  Create NixOS images suitable for initializing YubiKeys.

  This repository builds a bootable NixOS image that includes all of the software you need to initialize a YubiKey, and to configure it for use with Age, GnuPG and SSH. 

  It is important to note: 
  - This is not installing anything.
  - It runs in tmpfs in ram.
  - It leaves nothing behind.
  
  We follow recommended security practices by disabling network interfaces and running the configuration environment from an immutable ISO. The only way to write state to persistent storage is by explicit user action.

  This really all depends on how paranoid you want to be.

  Here is the workflow:

  Create an ISO image for Initializing a Yubikey.
  You can get very creative here, but just know this runs on an airgapped machine the whole time you are configuring the Yubikeys, so intrusion is very unlikely.

  This ISO image is minimal and pulled ONLY from trusted repositories.

  The image has zero ability to either write to the disk (it's mounted read-only), nor connect to anything, i.e. ssh, dns, etc. they are all disabled or removed.
  
  Once you disconnect the Yubikeys, They are immutable and have a matching set of PrivateKeys that CANNOT be exported.

  This also means that if you lose these keys, you are losing everything these keys produce or unlock.

  We ALWAYS make a pair (or more) of keys.

  One for usage, one for a backup.

  Make more backups if you choose, they all have to be made at the same time.

  There is NO OPTION to "clone" a Yubikey, it would be pretty useless if you could.

  So in essence, this becomes a physical access device that should be treated like the unique thing it is.

  Put one in a safe location that is fireproof, use the other daily.

  We actually recommend 3 at a minimum.

  Usually 2 matching devices and a 3rd for convenience or added security such as biometrics, or even just another backup.

  There are all kinds of gymnastics we can do here...

  Just remember, that if you lose them all, you lose everything they unlock.

  Our minimal recommendations, which are actually quite high:

- Create an ISO configuration.nix using a fixed version of NixOS (iow: not unstable, unless it is pointing to a git commit).
- build the ISO from a trusted machine
- use a NEW usb device and copy the ISO to it.
- using a trusted device:
  - If there is a cable plugged in, unplug it.
  - If you can physically turn off Wifi, do so.
- boot the device onto a fully network disconnected machine (airplane mode... turn all the radios off, which the ISO does.) 

Follow the instructions displayed.

The rest is a guided approach to initializing a set of Yubikeys.