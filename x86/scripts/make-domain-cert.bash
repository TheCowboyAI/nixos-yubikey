

expires="$(jq -r .org.yubikey.ssl.expiration <<< $secrets)"
org_name="$(jq -r .org.name <<< $secrets)"
orgid="$(jq -r .org.id <<< $secrets)"
common_name="$(jq -r .org.yubikey.ssl.common_name <<< $secrets)"
country="$(jq -r .org.country <<< $secrets)"
region="$(jq -r .org.region <<< $secrets)"
locality="$(jq -r .org.locality <<< $secrets)"
email="$(jq -r .org.email <<< $secrets)"
key_type_ssl="$(jq -r .org.yubikey.ssl.key_type <<< $secrets)"
dir="/ca/intermediate"

# create private key for wildcard cert
openssl ecparam -name $key_type_ssl \
  -genkey \
  -noout \
  -out $dir/private/wildcard.$common_name.private.key

# export its pubkey
openssl pkey \
  -in $dir/private/wildcard.$common_name.private.key \
  -pubout \
  -out $dir/wildcard.$common_name.public.key

# create the wildcard certificate signing request (csr)
openssl req -config $dir/openssl.cnf \
    -key $dir/private/wildcard.$common_name.private.key \
    -new -$keytype_ssl \
    -out $dir/csr/wildcard.$common_name.csr \

# create the cert
openssl ca -config $dir/openssl.cnf \
  -extensions server_cert \
  -days 375 \ 
  -notext \
  -md $key_type_ssl \
  -in $dir/csr/wildcard.$common_name.csr \
  -out $dir/certs/wildcard.$common_name.crt

jq -n \
--arg pubkey "$(cat $dir/wildcard.$common_name.public.key)" \
--arg privkey "$(cat $dir/private/wildcard.$common_name.private.key)" \
--arg crt "$(cat $dir/certs/wildcard.$common_name.crt)" \
"{WildcardCertificateCreated: {publickey: $pubkey, privatekey: $privkey, certificate: $crt}}" \
>> "$eventlog"
