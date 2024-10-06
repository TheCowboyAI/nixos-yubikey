{ pkgs }:
pkgs.writeShellScriptBin "make-rootca" ''
  openssl genpkey -algorithm $KEY_TYPE_AUTH -out $COMMON_NAME.pem

  $COMMON_NAME.csr<<EOF
  [req]
  distinguished_name = req_distinguished_name
  req_extensions = v3_req
  prompt = no
  
  [req_distinguished_name]
  C = $COUNTRY
  ST = $REGION
  L = $LOCALITY
  O = $ORG_NAME
  emailAddress = $EMAIL
  CN = $COMMON_NAME

  [v3_req]
  keyUsage = keyEncipherment, dataEncipherment
  extendedKeyUsage = serverAuth
  subjectAltName = @alt_names
  
  [alt_names]
  DNS.1 = *.$COMMON_NAME
  DNS.1 = *.dev.$COMMON_NAME
  EOF

  opessl req -new -out $

  # export its pubkey
  openssl pkey -in $COMMON_NAME.pem -pubout -out $COMMON_NAME.pub

  printf "\n$COMMON_NAME: %40s\nPublic Key: %40s\nPrivate Key: %40s\n\n" "$COMMON_NAME" "(cat $COMMON_NAME.pub)" "(cat $COMMON_NAME.pem)" | tee -a $LOGFILE
''
# you may wabt to pull these too.
