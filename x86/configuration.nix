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

  # enable filesystems
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

  # System packages
  environment.systemPackages = with pkgs; [
    cryptsetup
    git
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

    (import ./reset-keys.nix {inherit pkgs;})
    (import ./test-keys.nix {inherit pkgs;})
  ];

  services.udev.packages = [
    pkgs.yubikey-personalization
  ];

  services.pcscd.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -la";
    };

    histSize = 10000;

    loginShellInit = "";
  };

  security.sudo.wheelNeedsPassword = false;

  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$z4glAe5PkxpsXOOU$KyX75c.WfktMoP28c5Tssj9VW/tO7lhlWMCuPanu9YRXp2kLMt8q51r6LVKC3R75E04SKXEvJ2LOo2F92sfGj.";
    shell = pkgs.zsh;
  };

  services.getty.autologinUser = lib.mkForce "yubikey";
}
