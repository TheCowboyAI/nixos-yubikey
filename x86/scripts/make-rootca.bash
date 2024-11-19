# create root ca private key
openssl ecparam -name $KEY_TYPE_SSL -genkey -noout -out $COMMON_NAME.pem

# export it's public key
openssl pkey -in $COMMON_NAME.pem -pubout -out $COMMON_NAME.pub

# create root ca
openssl req -x509 -new \
-key $COMMON_NAME.pem \
-days $EXPIRATION_D \
-subj "/C=$COUNTRY/ST=$REGION/L=$LOCALITY/O=$ORG_NAME/CN=$COMMON_NAME/emailAddress=$EMAIL" \
-out $COMMON_NAME.crt

jq -c \
--arg pubkey "$(cat $COMMON_NAME.pub)" \
--arg privkey "$(cat $COMMON_NAME.pem)" \
--arg cert $(cat $COMMON_NAME.crt) \
--arg kt $KEY_TYPE_SSL \
". + {RootCaCertificateCreated: {public-key: $pubkey, private-key: $privkey, certificate: $cert, key-type: $kt}}" \
"$EVENTLOG" >> "$EVENTLOG"

# configure csr
"$COMMON_NAME".root-ca.csr.conf<<EOF
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
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $COMMON_NAME
EOF

# Create csr
openssl req -new -key $COMMON_NAME.pem -out $COMMON_NAME-root-ca.csr -subj "/C=$COUNTRY/ST=$REGION/L=$LOCALITY/O=$ORG_NAME/CN=$COMMON_NAME/emailAddress=$EMAIL"

# eventlog
jq -c \
--arg csr "$(cat $COMMON_NAME.root-ca.csr)" \
"{WildcardCsrCreated: {rootca-csr: $csr}}" \
"$EVENTLOG" >> "$EVENTLOG"


# sign with keyid
openssl x509 -req -in $COMMON_NAME-root-ca.csr -CA $KEYID -CAkey $KEYID-certify.pem -CAcreateserial -out $COMMON_NAME.root-ca.pem -days $EXPIRATION_D -sha512

# export the public key
openssl pkey -in $COMMON_NAME.root-ca.pem -pubout -out $COMMON_NAME.root-ca.pub

rootcasignedevt=$( jq -n \
--arg pubkey "$(cat $COMMON_NAME.root-ca.pub)" \
--arg privkey "$(cat $COMMON_NAME.root-ca.pem)" \
--arg cert $(cat $COMMON_NAME.crt) \
"{RootCaCertificateSigned: {public-key: $pubkey, private-key: $privkey, certificate: $cert}}"
)
eventlog "$rootcasignedevt"
