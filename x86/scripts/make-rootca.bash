function eventlog {
echo "$evt" >> "$EVENTLOG"
local evt = "$1"
}

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

rootcaevt=$( jq -n \
--arg pubkey "$(cat $COMMON_NAME.pub)" \
--arg privkey "$(cat $COMMON_NAME.pem)" \
--arg cert $(cat $COMMON_NAME.crt) \
"{RootCaCertificateCreated: {public-key: $pubkey, private-key: $privkey, certificate: $cert}}"
)
eventlog "$rootcaevt"
