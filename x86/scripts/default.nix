{ pkgs, ... }:
{
  imports = [
    ./add-key.nix
    ./enable-fido.nix
    ./completely-reset-my-yubikey.nix
    ./edit-env.nix
    ./enable-pgp-touch.nix
    ./enable-piv-touch.nix
    ./make-certkey.nix
    ./make-domain-cert.nix
    ./make-rootca.nix
    ./make-subkeys.nix
    ./make-tls-client.nix
    ./random-6.nix
    ./random-8.nix
    ./random-mgmt-key.nix
    ./random-pass.nix
    ./set-attributes.nix
    ./set-fido-pin.nix
    ./set-fido-retries.nix
    ./set-oauth-password.nix
    ./set-pgp-pins.nix
    ./set-piv-pins.nix
    ./set-yubikey.nix
    ./xfer-certs.nix
    ./xfer-keys.nix
  ];
  # System packages
  environment.systemPackages = [
    (import ./get-env.nix { inherit pkgs; })
    (import ./get-serials.nix { inherit pkgs; })
    (import ./get-status.nix { inherit pkgs; })
    (import ./help.nix { inherit pkgs; })
    (import ./move-revocation.nix { inherit pkgs; })
    (import ./set-env.nix { inherit pkgs; })
    (import ./verify-xfer.nix { inherit pkgs; })
  ];
}
