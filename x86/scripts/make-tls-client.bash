

org_name="$(jq -r .org.name <<< $secrets)"
orgid="$(jq -r .org.id <<< $secrets)"
country="$(jq -r .org.country <<< $secrets)"
region="$(jq -r .org.region <<< $secrets)"
locality="$(jq -r .org.locality <<< $secrets)"
emails="$(jq -r ..people[].email <<< $secrets)"
common_name="$(jq -r .org.yubikey.ssl.common_name <<< $secrets)"
key_type="$(jq -r .org.yubikey.ssl.key_type <<< $secrets)"
expires="$(jq -r .org.yubikey.ssl.expiration <<< $secrets)"
$dir="/ca/intermediate"

# clients for people with emails
for email in $emails; do
  # create the private key  
  openssl ecparam -name $key_type -genkey \
    -noout \
    -out $dir/private/$email.tlsclient.$common_name.private.key

  # export its pubkey
  openssl pkey \
    -in $dir/private/$email.tlsclient.$common_name.private.key \
    -pubout \
    -out $dir/$email.tlsclient.$common_name.public.key

  # create the csr
  openssl req -new \
    -key $dir/private/$email.tlsclient.$common_name.private.key \
    -out $dir/$email.tlsclient.$common_name.csr \
    -subject="/C=$country/ST=$region/L=$locality/O=$org_name/OU=$orgid/CN=$common_name/emailAddress=$email" 

  # export the certificate
  openssl x509 -req -in tlsclient.$common_name.csr \
    -CA $dir/certs/$common_name.authca.crt \
    -CAkey $dir/private/$common_name.authca.private.key \
    -CAcreateserial \
    -out $dir/certs/$email.tlsclient.$common_name.crt \
    -days $expires

  # export a certificate bundle
  openssl pkcs12 -export \
    -out $dir/certs/$email.tlsclient.full.pfx \
    -inkey $dir/private/$email.tlsclient.$common_name.private.key \
    -in $dir/certs/$email.tlsclient.$common_name.crt \
    -certfile $dir/certs/$common_name.authca.crt \
    -certfile /ca/certs/$common_name.rootca.crt

  jq -n \
    --arg pubkey $(cat $dir/$email.tlsclient.$common_name.public.key) \
    --arg privkey $(cat $dir/private/$email.tlsclient.$common_name.private.key) \
    --arg crt $(cat $dir/certs/$email.tlsclient.$common_name.crt) \
  "{SslClientCertificateCreated:{name: $email.tlsclient.$common_name, publickey: $pubkey, privatekey: $privkey, certificate: $crt}}"
  >> "$eventlog"
done
