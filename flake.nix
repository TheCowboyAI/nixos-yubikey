{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, disko, nixpkgs }: {
    nixosConfigurations.nixos-yubikey = nixpkgs.legacyPackages.x86_64-linux.nixos [
      ./configuration.nix
      disko.nixosModules.disko
      {
        disko.devices = {
          disk = {
            main = {
              # When using disko-install, we will overwrite this value from the commandline
              device = "/dev/sda";
              type = "disk";
              content = {
                type = "gpt";
                partitions = {
                  MBR = {
                    type = "EF02"; # for grub MBR
                    size = "1M";
                    priority = 1; # Needs to be first partition
                  };
                  ESP = {
                    type = "EF00";
                    size = "500M";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                    };
                  };
                  root = {
                    size = "100%";
                    content = {
                      type = "filesystem";
                      format = "ext4";
                      mountpoint = "/";
                    };
                  };
                };
              };
            };
          };
        };
      }
    ];
  };
}

# sudo nix run 'github:nix-community/disko#disko-install' -- --flake <flake-url>#<flake-attr> --disk <disk-name> <disk-device>

