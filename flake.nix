{
  description = "A test environment for Yubikeys";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = with pkgs; mkShell {
          packages = [
            cryptsetup
            age
            git
            just
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

            yubikey-manager
            yubikey-manager-qt
            yubikey-personalization
            age-plugin-yubikey
            piv-agent

            pkg-config
            bat
            jq
            ncdu
            lsd
            btop
            ranger
            eza
            fd
            fastfetch
            zsh
            starship
          ];

          shellHook = ''
            alias ls=eza
            alias find=fd
          '';
        };
      }
    );
}
