{ pkgs }:
pkgs.writeShellScriptBin "set-attributes" /*bash*/''

# TODO

  gpg --command-fd=0 --pinentry-mode=loopback --edit-card <<EOF
  admin
  login
  $IDENTITY
  $GPG_PIN
  quit
  EOF
''
