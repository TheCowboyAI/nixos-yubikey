{ pkgs }:
pkgs.writeShellScriptBin "make-rootca" /*bash*/''
  csr.conf<<EOF
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

  openssl genpkey -algorithm $KEY_TYPE_AUTH -out $COMMON_NAME.pem
  openssl req -new -key $COMMON_NAME.pem -out $COMMON_NAME.csr -config csr.conf
  openssl x509 -req -days $EXPIRATION_D -in $COMMON_NAME.csr -signkey $COMMON_NAME.pem -out $COMMON_NAME.crt -extensions req_ext -extfile csr.conf

  # export its pubkey
  openssl pkey -in $COMMON_NAME.pem -pubout -out $COMMON_NAME.pub

  printf "\n$COMMON_NAME: %40s\nPublic Key: %40s\nPrivate Key: %40s\n\n" "$COMMON_NAME" "(cat $COMMON_NAME.pub)" "(cat $COMMON_NAME.pem)" | tee -a $LOGFILE
''

