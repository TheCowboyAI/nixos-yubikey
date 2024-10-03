{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, disko, nixpkgs, agenix, ... }: {
    nixosConfigurations = {
      nixos-yubikey = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          ./configuration.nix
        ];
      };
    };
  };
}

# sudo nix run 'github:nix-community/disko#disko-install' -- --write-efi-boot-entries --flake <flake-url>#<flake-attr> --disk <disk-name> <disk-device>

