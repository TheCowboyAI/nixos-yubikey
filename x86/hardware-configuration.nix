# This is as minimal as possible.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # set paths
  systemd.tmpfiles.rules = [
    "d /var/ca 0755 yubikey users"
    "d /var/ca/certs 0755 yubikey users"
    "d /var/ca/csr 0755 yubikey users"
    "d /var/ca/crl 0755 yubikey users"
    "d /var/ca/private 0755 yubikey users"
    "d /var/ca/intermediate 0755 yubikey users"
    "d /var/ca/intermediate/certs 0755 yubikey users"
    "d /var/ca/intermediate/csr 0755 yubikey users"
    "d /var/ca/intermediate/crl 0755 yubikey users"
    "d /var/ca/intermediate/private 0755 yubikey users"
    "d /var/gpg 0755 yubikey users"
    "d /var/gpg/private 0755 yubikey users"
    "d /var/gpg/fp 0755 yubikey users"
  ];

}
