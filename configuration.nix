{ config, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/profiles/hardened.nix>
    ];

  system.stateVersion = "24.05";

  # Boot settings for ISO
  #boot.isContainer = true;
  boot.kernelPackages = pkgs.linuxPackages;

  networking.hostName = "nixos-yubikey";

  # disable bluetooth
  hardware.bluetooth.enable = false;

  # disable network
  networking.useDHCP = false;
  networking.useNetworkd = false;
  networking.networkmanager.enable = false;
  networking.wireless.enable = false;

  # enable firewall and block all ports
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  # disable coredump that could be exploited later
  # and also slow down the system when something crash
  systemd.coredump.enable = false;

  # SSH configuration (optional)
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  # System packages
  environment.systemPackages = with pkgs; [
    zsh

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

    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    #yubikey-personalization-qt
    #yubikey-touch-detector
    #yubikey-agent
    age-plugin-yubikey
    #piv-agent
  ];
  services.udev.packages = [
    pkgs.yubikey-personalization
  ];
  services.pcscd.enable = true;

  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;  
  
  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$z4glAe5PkxpsXOOU$KyX75c.WfktMoP28c5Tssj9VW/tO7lhlWMCuPanu9YRXp2kLMt8q51r6LVKC3R75E04SKXEvJ2LOo2F92sfGj.";
    shell = pkgs.zsh;
  };
}
