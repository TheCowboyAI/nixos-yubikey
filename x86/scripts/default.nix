{ pkgs, ... }:
{
  imports = [
    ./enable-fido.nix
    ./completely-reset-my-yubikey.nix
    ./enable-pgp-touch.nix
    ./enable-piv-touch.nix
    ./logstart.nix
    ./jkey.nix
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
    ./set-fido.nix
    ./set-oauth.nix
    ./set-pgp.nix
    ./set-piv.nix
    ./set-yubikey.nix
    ./xfer-certs.nix
    ./xfer-keys.nix
  ];
  
}
