{ lib, config, pkgs, modulesPath, ... }:
{
  system.stateVersion = "24.05";

  system.copySystemConfiguration = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [
      "${modulesPath}/profiles/hardened.nix"
      ./hardware-configuration.nix
      ./disko.nix
    ];

  boot.kernelParams = [ ];
  boot.kernelPackages = pkgs.linuxPackages;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = true;

  # enable filesystems and usb/sd or it probably won't boot
  boot.initrd.availableKernelModules = [ "ext4" "vfat" "ahci" "nvme" "usb_storage" ];
  boot.initrd.supportedFilesystems = [ "ext4" "vfat" ];

  networking.hostName = "nixos-yubikey";

  # disable bluetooth
  hardware.bluetooth.enable = false;

  # disable network
  boot.initrd.network.enable = false;
  networking = {
    useDHCP = false;
    resolvconf.enable = false;
    dhcpcd.enable = false;
    dhcpcd.allowInterfaces = [ ];
    useNetworkd = false;
    networkmanager.enable = false;
    wireless.enable = false;
    interfaces = { };

    # enable firewall and block all ports
    firewall.enable = true;
    firewall.allowedTCPPorts = [ ];
    firewall.allowedUDPPorts = [ ];
  };

  # disable coredump that could be exploited later
  # and also slow down the system when something crash
  systemd.coredump.enable = false;

  services.openssh.enable = lib.mkForce false;
  services.agenix.enable = true;
  
  environment.home."yubikey/justfile" = ./justfile;

  # System packages
  environment.systemPackages = with pkgs; [
    cryptsetup
    git
    just
    gitAndTools.git-extras
    gnupg
    age
    pcsclite
    pcsctools
    pgpdump
    pinentry-curses
    pwgen
    gpg-tui
    openssh

    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    #yubikey-personalization-qt
    #yubikey-touch-detector
    #yubikey-agent
    age-plugin-yubikey
    piv-agent
    (import ./test-keys.nix { inherit pkgs; })
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = ''
personal-cipher-preferences AES256 AES192 AES
personal-digest-preferences SHA512 SHA384 SHA256
personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
cert-digest-algo SHA512
s2k-digest-algo SHA512
s2k-cipher-algo AES256
charset utf-8
no-comments
no-emit-version
no-greeting
keyid-format 0xlong
list-options show-uid-validity
verify-options show-uid-validity
with-fingerprint
require-cross-certification
no-symkey-cache
armor
use-agent
throw-keyids
    '';
  };

  # GPG chooses socket directory based on GNUPGHOME.
  # If any other user wants to use gpg-agent they are out of luck,
  # unless they modify the socket in their profile and those are locked.
  systemd.user.sockets.gpg-agent = {
    listenStreams = let
      user = "yubikey";
      socketDir = pkgs.runCommand "gnupg-socketdir" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        python3 ${../../common/gnupgdir.py} '/home/${user}/.local/share/gnupg' > $out
      '';
    in [
      "" # unset
      "%t/gnupg/${builtins.readFile socketDir}/S.gpg-agent"
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -la";
    };

    histSize = 10000;
    #loginShellInit = " ";
  };
  # the above should work, but doesn't
  system.activationScripts.script.text = "touch /home/yubikey/.zshrc";

  security.sudo.wheelNeedsPassword = false;

  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$z4glAe5PkxpsXOOU$KyX75c.WfktMoP28c5Tssj9VW/tO7lhlWMCuPanu9YRXp2kLMt8q51r6LVKC3R75E04SKXEvJ2LOo2F92sfGj.";
    shell = pkgs.zsh;
  };

  services.getty.autologinUser = lib.mkForce "yubikey";
}
