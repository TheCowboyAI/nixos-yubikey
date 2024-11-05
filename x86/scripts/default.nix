{ pkgs, ... }:
{
  imports = [
    ./add-key.nix
  ];
  # System packages
  environment.systemPackages = [
    (import ./completely-reset-my-yubikey.nix { inherit pkgs; })
    (import ./edit-env.nix { inherit pkgs; })
    (import ./enable-fido2.nix { inherit pkgs; })
    (import ./enable-pgp-touch.nix { inherit pkgs; })
    (import ./enable-piv-touch.nix { inherit pkgs; })
    (import ./get-env.nix { inherit pkgs; })
    (import ./get-serials.nix { inherit pkgs; })
    (import ./get-status.nix { inherit pkgs; })
    (import ./help.nix { inherit pkgs; })
    (import ./make-certkey.nix { inherit pkgs; })
    (import ./make-domain-cert.nix { inherit pkgs; })
    (import ./make-rootca.nix { inherit pkgs; })
    (import ./make-subkeys.nix { inherit pkgs; })
    (import ./make-tls-client.nix { inherit pkgs; })
    (import ./move-revocation.nix { inherit pkgs; })
    (import ./random-6.nix { inherit pkgs; })
    (import ./random-8.nix { inherit pkgs; })
    (import ./random-mgmt-key.nix { inherit pkgs; })
    (import ./random-pass.nix { inherit pkgs; })
    (import ./set-attributes.nix { inherit pkgs; })
    (import ./set-env.nix { inherit pkgs; })
    (import ./set-fido-pin.nix { inherit pkgs; })
    (import ./set-fido-retries.nix { inherit pkgs; })
    (import ./set-oauth-password.nix { inherit pkgs; })
    (import ./set-pgp-pins.nix { inherit pkgs; })
    (import ./set-piv-pins.nix { inherit pkgs; })
    (import ./set-yubikey.nix { inherit pkgs; })
    (import ./verify-xfer.nix { inherit pkgs; })
    (import ./xfer-certs.nix { inherit pkgs; })
    (import ./xfer-keys.nix { inherit pkgs; })
  ];
}
