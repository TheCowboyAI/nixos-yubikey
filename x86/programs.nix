{ pkgs, ... }:
{
  # modules
  enable-fido.enable = true;
  completely-reset-my-yubikey.enable = true;
  enable-pgp-touch.enable = true;
  enable-piv-touch.enable = true;
  logstart.enable = true;
  jkey.enable = true;
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
  set-fido.enable = true;
  set-oauth.enable = true;
  set-pgp.enable = true;
  set-piv.enable = true;
  set-yubikey.enable = true;
  xfer-certs.enable = true;
  xfer-keys.enable = true;

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
    openssl
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

  programs.yubikey-touch-detector.enable = true;
  programs.yubikey-touch-detector.libnotify = true;

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
    loginShellInit = "";
  };
  system.userActivationScripts.zshrc = "touch .zshrc";
  system.userActivationScripts.ca = ''
  touch /var/ca/index.txt \
  && echo 1000 > /var/ca/intermediate/crlnumber \
  && echo 1000 > /var/ca/intermediate/serial
  '';
  system.userActivationScripts.secrets = "export secrets=$(<'/home/yubikey/secrets.json')";
}
