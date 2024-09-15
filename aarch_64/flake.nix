{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, disko, nixpkgs, ... }: {
    nixosConfigurations = {
      nixos-yubikey = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };
    };
  };
}

# sudo nix run 'github:nix-community/disko#disko-install' -- --write-efi-boot-entries --flake <flake-url>#<flake-attr> --disk <disk-name> <disk-device>

