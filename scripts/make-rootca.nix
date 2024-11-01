{ pkgs }:
pkgs.writeShellScriptBin "make-rootca" /*bash*/''
  function eventlog(evt) {echo evt >> $EVENTLOG}

  # sanity check //todo
  # if !$COMMON_NAME||!$COMMON_NAME||$COUNTRY then
  #   //exit asking to set env
  # end if

  # create root ca private key
  openssl ecparam -name $KEY_TYPE_SSL -genkey -noout -out $COMMON_NAME.pem
  rootkey-evt = "{'rootca-private-key-created':{'rootca-privatekey':'(cat $COMMON_NAME.pem)'}}"
  eventlog rootkey-evt

  # export it's public key
  openssl pkey -in $COMMON_NAME.pem -pubout -out $COMMON_NAME.pub

  # create root ca
  openssl req -x509 -new \
    -key $COMMON_NAME.pem \
    -days $EXPIRATION_D \
    -subj "/C=$COUNTRY/ST=$REGION/L=$LOCALITY/O=$ORG_NAME/CN=$COMMON_NAME/emailAddress=$EMAIL" \
    -out $COMMON_NAME.crt
  rootca-evt = "{'rootca-certificate-created':{'rootca-cert':'$COMMON_NAME.crt'}}"
  eventlog rootca-evt
''
  