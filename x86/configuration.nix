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

  # System packages
  environment.systemPackages = with pkgs; [
    cryptsetup
    git
    just
    micro
    gitAndTools.git-extras
    gnupg
    pcsclite
    pcsctools
    pgpdump
    pinentry-curses
    pwgen
    gpg-tui
    openssh
    jq
    jc
    glow

    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    age-plugin-yubikey
    piv-agent
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  services.pcscd.enable = true;
  services.yubikey-agent.enable = true;

  programs.gnupg = {
    dirmngr.enable = true;
    agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = true;
      settings = {
        default-cache-ttl = "600";
        max-cache-ttl = "7200";
      };
    };
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
    loginShellInit = "source ~/.env";
  };

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
}
