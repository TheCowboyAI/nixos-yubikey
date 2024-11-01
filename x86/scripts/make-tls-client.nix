{ pkgs }:
pkgs.writeShellScriptBin "make-tls-client" /*bash*/''
    function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  # create the private key  
  openssl ecparam -name $KEY_TYPE_SSL -genkey -noout \
  -out sslclient.$COMMON_NAME.pem

  # export its pubkey
  openssl pkey -in sslclient.$COMMON_NAME.pem -pubout -out sslclient.$COMMON_NAME.pub

  clientkey-evt = "{'sslclient-private-key-created':{'sslclient-privatekey':'(cat sslclient.$COMMON_NAME.pem)'}}"
  eventlog clientkey-evt

  # create the csr
  openssl req -new -key sslclient.$COMMON_NAME.pem \
  -out sslclient.$COMMON_NAME.csr \
  -subj "/C=$X_COUNTRY/ST=$X_REGION/L=$X_LOCALITY/O=$X_ORG_NAME/CN=$X_COMMON_NAME"

  csr-evt = "{'sslclient-csr-created':{'sslclient-csr':'sslclient.$COMMON_NAME.csr'}}"
  eventlog csr-evt

  # sign the csr
  openssl x509 -req -in sslclient.$COMMON_NAME.csr \
  -CA $COMMON_NAME.crt -CAkey $COMMON_NAME.pem -CAcreateserial \
  -out sslclient.$COMMON_NAME.crt -days $EXPIRATION_D

  clientcrt-evt = "{'sslclient-certificate-created':{'sslclient-certificate':'sslclient.$COMMON_NAME.crt'}}"
  eventlog clientcrt-evt  
''
