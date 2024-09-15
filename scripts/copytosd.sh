sudo nix run 'github:nix-community/disko#disko-install' -- --write-efi-boot-entries --flake .#nixos-yubikey --disk main /dev/sda
