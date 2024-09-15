   - [[https://github.com/drduh/YubiKey-Guide][DrDuh's YubiKey guide]]

     This one is my personal favorite. Note that the ~gpg.conf~
     referred to in this guide is already set up for you when you open
     a shell in the NixOS YubiKey image.

   - [[https://rzetterberg.github.io/yubikey-gpg-nixos.html][Setting up GnuPG + YubiKey on NixoS for SSH authentication]]

     Contains some NixOS-specific information, all of which has been
     incorporated into this NixOS YubiKey image.

   - [[https://www.forgesi.net/gpg-ssh-with-the-yubikey-5/][GPG/SSH with the YubiKey 5]]

     Probably the next best guide I found after DrDuh's guide.

   - [[https://www.andreagrandi.it/2017/09/30/configuring-offline-gnupg-masterkey-subkeys-on-yubikey/][Configuring an offline GnuPG master key and subkeys on YubiKey]]

   - [[https://shankarkulumani.com/2019/03/gpg.html][Starting with GPG and YubiKey]]

     Probably the most "gentle" of the guides.

*** Renewing subkeys

    DrDuh's guide [[https://github.com/drduh/YubiKey-Guide#renewing-sub-keys][now covers subkey renewal]], which is much simpler
    than rotating keys. Note that once you've renewed your subkeys,
    you'll need to re-export your keys (including the public key,
    which will need to be updated in all the usual places), but you do
    *not* need to update the subkeys on the YubiKey.
    
** Other useful information

   Debian's (and Debian developers') guides to using subkeys and why
   they're useful are probably the best resources on these topics,
   though they're not specific to YubiKeys (or even hardware keys at
   all):

   - [[https://wiki.debian.org/Subkeys][Using OpenPGP subkeys in Debian development]]

   - [[https://wiki.debian.org/OfflineMasterKey][Offline master key]]

   - [[https://wiki.debian.org/GnuPG/AirgappedMasterKey][Airgapped master key]]

   - [[https://github.com/tomlowenthal/documentation/blob/master/gpg/smartcard-keygen.md][Smartcard keygen]]

   This guide doesn't cover Yubikeys in any depth, but it does a good
   job of covering out to create additional GPG ID's (i.e., additional
   email addresses associated with your key), and also more
   information on how to use ~hopenpgp-tools~ and ~pgpdump~:

   - [[https://blog.tinned-software.net/create-gnupg-key-with-sub-keys-to-sign-encrypt-authenticate/][Create GnuPG with sub-keys to sign, encrypt, authenticate]]

   Everyone recommends using a 2nd YubiKey to make a backup of your
   primary YubiKey, but in practice, using 2 or more YubiKeys with the
   same subkeys is tricky. Here are some resources for more
   information on this subject, plus the currently best-known
   workarounds:

   - [[https://github.com/drduh/YubiKey-Guide/issues/19][Using two yubikeys not covered under guide]]

   - [[https://forum.yubico.com/viewtopic38a1.html?f=35&t=2400#p10091][Use PGP keys on multiple yubikeys]]

   If you want to use your Yubikey with VMware Workstation or VMware
   Fusion, you'll need to edit your virtual machine's VMX file:

   - [[https://support.yubico.com/support/solutions/articles/15000008891-troubleshooting-vmware-workstation-device-passthrough][Troubleshooting VMWare Workstation Device Passthrough]]
