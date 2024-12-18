source jkey

expires="$(jkey ssl.expiration)"
org_name="$(jkey org.name)"
orgid="$(jkey org.id)"
common_name="$(jkey ssl.common_name)"
country="$(jkey org.country)"
region="$(jkey org.region)"
locality="$(jkey org.locality)"
email="$(jkey org.email)"
key_type_ssl="$(jkey ssl.key_type)"
dir="/root/ca/intermediate"

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
