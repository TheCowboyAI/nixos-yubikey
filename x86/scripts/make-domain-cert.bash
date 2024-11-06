function eventlog {
  local evt="$1"
  echo "$evt" >> "$EVENTLOG"
}

# sanity check //todo
# if !$COMMON_NAME||!$COMMON_NAME||$COUNTRY then
#   //exit asking to set env
# end if

# create private key for wildcard cert
openssl ecparam -name $KEY_TYPE_SSL -genkey -noout -out wildcard.$COMMON_NAME.pem

# create the wildcard certificate signing request (csr)
openssl req -new -key wildcard.$COMMON_NAME.pem \
-subj "/C=$COUNTRY/ST=$REGION/L=$LOCALITY/O=$ORG_NAME/CN=*.$COMMON_NAME/emailAddress=$EMAIL" \
-out wildcard.$COMMON_NAME.csr

csrevt=$( jq -n \
--arg csr "$(cat wildcard.$COMMON_NAME.csr)" \
"{WildcardCsrCreated: {wildcard-csr: $csr}}")
eventlog "$certevt"

wildcard."$COMMON_NAME".csr.conf<<EOF
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
CN = *.$COMMON_NAME

[v3_req]
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $COMMON_NAME
DNS.2 = *.$COMMON_NAME
EOF

# Sign the CSR with the Root CA to generate the wildcard certificate
openssl x509 -req -in wildcard.$COMMON_NAME.csr \
-CA $COMMON_NAME.crt \
-CAkey wildcard.$COMMON_NAME.pem \
-CAcreateserial \
-out wildcard.$COMMON_NAME.crt -days $EXPIRATION_D \
-extfile wildcard.$COMMON_NAME.cnf -extensions v3_req

# export its pubkey
openssl pkey -in wildcard.$COMMON_NAME.pem -pubout -out wildcard.$COMMON_NAME.pub

signevt=$( jq -n \
--arg pubkey "$(cat wildcard.$COMMON_NAME.pub)" \
--arg privkey "$(cat wildcard.$COMMON_NAME.pem)" \
--arg crt "$(cat wildcard.$COMMON_NAME.crt)" \
--arg cnf "$(cat wildcard.$COMMON_NAME.cnf)" \
"{WildcardCertificateCreated: {public-key: $pubkey, private-key: $privkey, certificate: $crt, confirmation: $cnf}}"
)

eventlog "$signevt"
