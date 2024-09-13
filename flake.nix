{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, disko, nixpkgs, ... }: {
    nixosConfigurations.nixos-yubikey = nixpkgs.legacyPackages.x86_64-linux.nixos [
      ./configuration.nix
      ./disko.nix
    ];
  };
}

# sudo nix run 'github:nix-community/disko#disko-install' -- --write-efi-boot-entries --flake <flake-url>#<flake-attr> --disk <disk-name> <disk-device>

