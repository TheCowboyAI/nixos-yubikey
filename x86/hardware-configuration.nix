# This is as minimal as possible.
{ config, lib, pkgs, modulesPath, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ ];
    kernelPackages = pkgs.linuxPackages;
    extraModulePackages = [ ];

    initrd = {
      kernelModules = [ ];
      availableKernelModules = [ "ext4" "vfat" "ahci" "nvme" "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      # enable filesystems and usb/sd or it probably won't boot
      supportedFilesystems = [ "ext4" "vfat" ];
      # disable network
      network.enable = false;
    };

    loader = {
      grub.enable = false;
      systemd-boot.enable = lib.mkForce true;
      efi.canTouchEfiVariables = true;
    };
  };

  # disable bluetooth
  hardware = {
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
