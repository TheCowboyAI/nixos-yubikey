source jkey

org_name="$(jkey org.name)"
orgid="$(jkey org.id)"
country="$(jkey org.country)"
region="$(jkey org.region)"
locality="$(jkey org.locality)"
emails="$(jkey .people[].email)"
common_name="$(jkey ssl.common_name)"
key_type="$(jkey ssl.key_type)"
expires="$(jkey ssl.expiration)"
$dir="/root/ca/intermediate"

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
    -certfile /root/ca/certs/$common_name.rootca.crt

  jq -n \
    --arg pubkey $(cat $dir/$email.tlsclient.$common_name.public.key) \
    --arg privkey $(cat $dir/private/$email.tlsclient.$common_name.private.key) \
    --arg crt $(cat $dir/certs/$email.tlsclient.$common_name.crt) \
  "{SslClientCertificateCreated:{name: $email.tlsclient.$common_name, publickey: $pubkey, privatekey: $privkey, certificate: $crt}}"
  >> "$eventlog"
done
