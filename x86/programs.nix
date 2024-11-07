{ pkgs, ... }:
{
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
}
