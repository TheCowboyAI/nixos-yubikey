{ lib, config, pkgs, modulesPath, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [
    ];

  system.stateVersion = "24.05";

  boot.kernelParams = [ ]; # "copytoram"

  # Boot settings for ISO
  boot.kernelPackages = pkgs.linuxPackages;
  networking.hostName = "nixos-yubikey";

  # System packages
  environment.systemPackages = with pkgs; [
    git
    gitAndTools.git-extras
    gnupg
    age
    pwgen
    openssh
  ];

  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$z4glAe5PkxpsXOOU$KyX75c.WfktMoP28c5Tssj9VW/tO7lhlWMCuPanu9YRXp2kLMt8q51r6LVKC3R75E04SKXEvJ2LOo2F92sfGj.";
    shell = pkgs.zsh;
  };
}
