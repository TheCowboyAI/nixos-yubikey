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

    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    age-plugin-yubikey
    piv-agent

    #scripts
    (import scripts/completely-reset-my-yubikey.nix {inherit pkgs;})
    (import scripts/edit-env.nix {inherit pkgs;})
    (import scripts/enable-fido2.nix {inherit pkgs;})
    (import scripts/enable-pgp-touch.nix {inherit pkgs;})
    (import scripts/enable-piv-touch.nix {inherit pkgs;})
    (import scripts/get-env.nix {inherit pkgs;})
    (import scripts/get-status.nix {inherit pkgs;})
    (import scripts/make-certkey.nix {inherit pkgs;})
    (import scripts/make-domain-cert.nix {inherit pkgs;})
    (import scripts/make-rootca.nix {inherit pkgs;})
    (import scripts/make-subkeys.nix {inherit pkgs;})
    (import scripts/make-tls-client.nix {inherit pkgs;})
    (import scripts/random-6.nix {inherit pkgs;})
    (import scripts/random-8.nix {inherit pkgs;})
    (import scripts/random-mgmt-key.nix {inherit pkgs;})
    (import scripts/random-pass.nix {inherit pkgs;})
    (import scripts/set-attributes.nix {inherit pkgs;})
    (import scripts/set-backup-key.nix {inherit pkgs;})
    (import scripts/set-env.nix {inherit pkgs;})
    (import scripts/set-fido-pin.nix {inherit pkgs;})
    (import scripts/set-fido-retries.nix {inherit pkgs;})
    (import scripts/set-oauth-password.nix {inherit pkgs;})
    (import scripts/set-pgp-pins.nix {inherit pkgs;})
    (import scripts/set-piv-pins.nix {inherit pkgs;})
    (import scripts/set-yubikey.nix {inherit pkgs;})
    (import scripts/verify-xfer.nix {inherit pkgs;})
    (import scripts/xfer-cert.nix {inherit pkgs;})
    (import scripts/xfer-keys.nix {inherit pkgs;})
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  services.pcscd.enable = true;
  services.yubikey-agent.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      require-cross-certification = true;
      no-symkey-cache = true;
      armor = true;
      use-agent = true;
      throw-keyids = true;
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
}
