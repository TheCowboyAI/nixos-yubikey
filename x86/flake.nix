{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, disko, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        nixos-yubikey = nixpkgs.lib.nixosSystem {
          system = "${system}";
          modules = [
            disko.nixosModules.disko
            ./configuration.nix
          ];
        };
      };
      devShells.${system}.default = pkgs.mkShell {

        packages = with pkgs; [
          pkg-config
          eza
          fd
          fastfetch
          zsh
          starship
          nixfmt-rfc-style

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

        shellHook = ''
          alias ls=eza
          alias find=fd
        '';
      };
    };
}


