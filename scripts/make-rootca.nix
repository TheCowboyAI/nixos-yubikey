{ pkgs }:
pkgs.writeShellScriptBin "make-rootca" ''
  openssl genpkey -algorithm $KEY_TYPE -out $COMMON_NAME.key
''
# you may wabt to pull these too.
