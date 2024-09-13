# Initialize Yubikey Set
This is our process for creating Yubikey sets in a safe manner.

We have created a nix Flake that will create a bootable usb or sd card to format a machine into a safe, AIR-GAPPED Environment.

The Environment is very minimal on purpose.
The ONLY purpose to run is to initialize a set of Yubikeys and therefore, it is hardened and anything not required is removed or blocked.

This is not a general recovery usb stick.

It is purpose driven and is ephemeral activity.

The intent is that you boot this usb...
Follow the instructions provided.
Turn OFF the machine we used.
unplug the usb.
store it with your backup Yubikey.

This provides an audit trail for how the key was made.
It DOES NOT provide any keys, those solely reside on the Yubikey.

Why do we need hardening?

We want an environment as safe as writing a bunch of symbols on a piece of paper and hiding the paper.

Of course paper can't talk to a machine, but you can copy it by taking a picture.

Once you create a PrivateKey on a Yubikey, it ONLY resides there and cannot be copied, cloned, or duplicated in any way.

The PrivateKey can be authenticated, but not copied or placed in memory somewhere.

The reason we harden the system this is created on is that we want to be absolutely certain this Key cannot be tampered with.

We want a trusted device to run a trusted application to create security keys.

These "master" keys should never be exposed to the internet or any other machine while initializing.

This is what the hardened ISO/SD does. It is a vault where you can safely work on keys. It is saved with the key in case somehow if it is ever compromised, we have an audit trail of how it was made, including all the running software by exact version.

This is quite literally the key to your Safety Deposit Box where you create other keys.

The Master Key is generally used "once" when creating a Domain. After that, the Master Key is used to link to other revocable keys. 

Your GnuPG master key is also your “identity” among every PGP user. If you loose your master key or if your key is compromised you need to rebuild your identity and reputation from scratch. Instead, if a subkey is compromised, you can revoke the subkey (using your master key) and generate a new subkey.

We also will make a set of "personal" Yubikeys.

This is our Personal Physical Authenticator.
It can be asked to reply for verification or for two factor authentication.

This makes human verification very simple in a workflow.

