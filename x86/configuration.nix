{ lib, pkgs, modulesPath, ... }:
{
  system.stateVersion = "24.05";
  system.copySystemConfiguration = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [
      "${modulesPath}/profiles/hardened.nix"
      ./hardware-configuration.nix
      ./disko.nix
      ./scripts
      ./programs
    ];

  networking.hostName = "nixos-yubikey";
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

  system.activationScripts.script.text = "touch /home/yubikey/.zshrc";

  security.sudo.wheelNeedsPassword = false;

  # giving root a password enables su which we may want
  users.users.root = {
    isSystemUser = true;
    hashedPassword = "$6$z4glAe5PkxpsXOOU$KyX75c.WfktMoP28c5Tssj9VW/tO7lhlWMCuPanu9YRXp2kLMt8q51r6LVKC3R75E04SKXEvJ2LOo2F92sfGj.";
    shell = pkgs.zsh;
  };

  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$z4glAe5PkxpsXOOU$KyX75c.WfktMoP28c5Tssj9VW/tO7lhlWMCuPanu9YRXp2kLMt8q51r6LVKC3R75E04SKXEvJ2LOo2F92sfGj.";
    shell = pkgs.zsh;
    createHome = true;
    home = "/home/yubikey";
  };

  services.getty.autologinUser = lib.mkForce "yubikey";

  environment.etc."doc/help.md".source = ./scripts/readme.md;

  users.motd = ''
    NixOS Yubikey Configuration
    ==========================

    For instructions type: `help`

    To begin type: `set-yubikey`
    
  '';

  # scripts to enable
  add-key.enable = true;
  enable-fido.enable = true;
  completely-reset-my-yubikey.enable = true;
  edit-env.enable = true;
  enable-pgp-touch.enable = true;
  enable-piv-touch.enable = true;
  make-certkey.enable = true;
  make-domain-cert.enable = true;
  make-rootca.enable = true;
  make-subkeys.enable = true;
  make-tls-client.enable = true;
  random-6.enable = true;
  random-8.enable = true;
  random-mgmt-key.enable = true;
  random-pass.enable = true;
  set-attributes.enable = true;
  set-fido-pin.enable = true;
  set-fido-retries.enable = true;
  set-oauth-password.enable = true;
  set-pgp-pins.enable = true;
  set-piv-pins.enable = true;
  set-yubikey.enable = true;
  xfer-certs.enable = true;
  xfer-keys.enable = true;
}
