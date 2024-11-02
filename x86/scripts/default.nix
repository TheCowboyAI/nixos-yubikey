{ pkgs, ... }:
{
  # System packages
  environment.systemPackages = [
    (import scripts/completely-reset-my-yubikey.nix { inherit pkgs; })
    (import scripts/edit-env.nix { inherit pkgs; })
    (import scripts/enable-fido2.nix { inherit pkgs; })
    (import scripts/enable-pgp-touch.nix { inherit pkgs; })
    (import scripts/enable-piv-touch.nix { inherit pkgs; })
    (import scripts/get-env.nix { inherit pkgs; })
    (import scripts/get-serials.nix { inherit pkgs; })
    (import scripts/get-status.nix { inherit pkgs; })
    (import scripts/make-certkey.nix { inherit pkgs; })
    (import scripts/make-domain-cert.nix { inherit pkgs; })
    (import scripts/make-rootca.nix { inherit pkgs; })
    (import scripts/make-subkeys.nix { inherit pkgs; })
    (import scripts/make-tls-client.nix { inherit pkgs; })
    (import scripts/random-6.nix { inherit pkgs; })
    (import scripts/random-8.nix { inherit pkgs; })
    (import scripts/random-mgmt-key.nix { inherit pkgs; })
    (import scripts/random-pass.nix { inherit pkgs; })
    (import scripts/set-attributes.nix { inherit pkgs; })
    (import scripts/set-env.nix { inherit pkgs; })
    (import scripts/set-fido-pin.nix { inherit pkgs; })
    (import scripts/set-fido-retries.nix { inherit pkgs; })
    (import scripts/set-oauth-password.nix { inherit pkgs; })
    (import scripts/set-pgp-pins.nix { inherit pkgs; })
    (import scripts/set-piv-pins.nix { inherit pkgs; })
    (import scripts/set-yubikey.nix { inherit pkgs; })
    (import scripts/verify-xfer.nix { inherit pkgs; })
    (import scripts/xfer-certs.nix { inherit pkgs; })
    (import scripts/xfer-keys.nix { inherit pkgs; })
  ];
}
