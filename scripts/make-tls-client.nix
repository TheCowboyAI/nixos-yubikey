{ pkgs }:
pkgs.writeShellScriptBin "make-tls-client" /*bash*/''
  openssl req -x509 -new -nodes -key $X_COMMON_NAME.key -$KEY_TYPE -days $CERT_EXPIRES -out $X_COMMON_NAME.crt
''
