source jkey
# see: https://openssl-ca.readthedocs.io/en/latest/create-the-root-pair.html

# set paths
mkdir -p $dir/{certs,crl,serial,private,intermediate/{certs crl csr private}}
echo 1000 > $dir/intermediate/crlnumber
echo 1000 > $dir/intermediate/serial
touch index.txt

# variables
org_publickey="$(cat ~/certify-$orgid.public.key)"
org_privatekey="$(cat ~/certify-$orgid.private.key)"
expires="$(jkey ssl.expiration)"
org_name="$(jkey org.name)"
orgid="$(jkey org.id)"
common_name="$(jkey ssl.common_name)"
country="$(jkey org.country)"
region="$(jkey org.region)"
locality="$(jkey org.locality)"
email="$(jkey org.email)"
key_type_auth="$(jkey pgp.key_type_auth)"
key_type_encr="$(jkey pgp.key_type_encr)"
key_type_sign="$(jkey pgp.key_type_sign)"
key_type_ssl="$(jkey ssl.key_type)"
dir="/root/ca"

# defining this eliminates guesswork of cli options and holds a file
$dir/openssl.cnf<<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = $dir
certs = \$dir/certs
crl_dir = \$dir/crl
database = \$dir/index.txt
serial = \$dir/serial
RANDFILE = \$dir/private/.rand

# The root key and root certificate.
private_key      = \$dir/private/$common_name.rootca.private.key
certificate      = \$dir/certs/$common_name.rootca.crt

# For certificate revocation lists.
crlnumber        = \$dir/crlnumber
crl              = \$dir/crl/$common_name.rootca.crl.pem
crl_extensions   = crl_ext
default_crl_days = 30

default_md       = $key_type_ssl

name_opt         = ca_default
cert_opt         = ca_default
default_days     = 375
preserve         = no
policy           = policy_strict

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of `man ca`.
countryName            = match
stateOrProvinceName    = match
organizationName       = match
organizationalUnitName = supplied
commonName             = supplied
emailAddress           = supplied

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the `ca` man page.
countryName            = optional
stateOrProvinceName    = optional
localityName           = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[ req ]
# Options for the `req` tool (`man req`).
default_bits       = 4096
distinguished_name = req_distinguished_name
string_mask        = utf8only

# we prefer ECC
default_md         = $key_type_ssl

# Extension to add when the -x509 option is used.
x509_extensions    = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
commonName                      = $common_name Root CA
countryName                     = $country
stateOrProvinceName             = $region
localityName                    = $locality
0.organizationName              = $org_name
organizationalUnitName          = $orgid
emailAddress                    = $email

[ v3_ca ]
# Extensions for a typical CA (`man x509v3_config`).
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:true
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (`man x509v3_config`).
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:true, pathlen:0
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates (`man x509v3_config`).
basicConstraints       = CA:FALSE
nsCertType             = client, email
nsComment              = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
keyUsage               = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage       = clientAuth, emailProtection

[ server_cert ]
# Extensions for server certificates (`man x509v3_config`).
basicConstraints       = CA:FALSE
nsCertType             = server
nsComment              = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage               = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth

[ crl_ext ]
# Extension for CRLs (`man x509v3_config`).
authorityKeyIdentifier = keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (`man ocsp`).
basicConstraints       = CA:FALSE
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
keyUsage               = critical, digitalSignature
extendedKeyUsage       = critical, OCSPSigning
EOF 

$dir/intermediate/openssl.cnf<<EOF
[ CA_default ]
dir         = $dir/intermediate
private_key = \$dir/private/$common_name.authca.private.key
certificate = \$dir/certs/$common_name.authca.crt
crl         = \$dir/crl/$common_name.authca.crl
serial      = \$dir/serial
database    = \$dir/index.txt
new_certs_dir = \$dir/certs
RANDFILE    = \$dir/private/.rand

policy      = policy_loose
copy_extensions = copy

[ req_distinguished_name ]
commonName                      = $common_name Authorized Root CA
countryName                     = $country
stateOrProvinceName             = $region
localityName                    = $locality
0.organizationName              = $org_name
organizationalUnitName          = $orgid
emailAddress                    = $email

[ server_cert ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1          = $common_name
DNS.2          = *.$common_name

[ usr_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ crl_ext ]
# Extension for CRLs (`man x509v3_config`).
authorityKeyIdentifier = keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (`man ocsp`).
basicConstraints       = CA:FALSE
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
keyUsage               = critical, digitalSignature
extendedKeyUsage       = critical, OCSPSigning
EOF

# create root ca private key
openssl ecparam -name $key_type_ssl -genkey \
  -noout \
  -out $dir/private/$common_name.rootca.private.key

# export it's public key
openssl pkey \
  -in $dir/private/$common_name.rootca.private.key \
  -pubout \
  -out $dir/$common_name.rootca.public.key

# create root ca
openssl req \
  -new -x509 \
  -days 7300 \
  -$key_type_ssl \
  -extensions v3_ca \
  -config $dir/openssl.cnf \
  -key $dir/private/$common_name.rootca.private.key \
  -out $dir/certs/$common_name.rootca.crt

jq -c \
--arg pubkey "$(cat $dir/$common_name.rootca.public.key)" \
--arg privkey "$(cat $dir/private/$common_name.rootca.private.key)" \
--arg cert $(cat $dir/certs/$common_name.rootca.crt) \
--arg kt $key_type_ssl \
". + {RootCACertificateCreated: {publickey: $pubkey, privatekey: $privkey, certificate: $cert, key-type: $kt}}" \
>> "$eventlog"

# create intermediate ca private key
openssl ecparam \
  -name $key_type_ssl -genkey \
  -noout \
  -out $dir/intermediate/private/$common_name.authca.private.key

# export it's public key
openssl pkey \
  -in $dir/intermediate/private/$common_name.authca.private.key \
  -pubout \
  -out $dir/intermediate/$common_name.authca.public.key

# create auth ca
openssl req \
  -new -x509 \
  -days $expiration \
  -$key_type_ssl \
  -extensions v3_ca \
  -config $dir/intermediate/openssl.cnf \
  -key $dir/intermediate/private/$common_name.authca.private.key \
  -out $dir/intermediate/certs/$common_name.authca.crt

# create signing chain (what we distribute)
cat $dir/intermediate/certs/$common_name.authca.crt $dir/certs/$common_name.rootca.crt > \
    intermediate/certs/$common_name.ca-chain.crt

jq -c \
--arg pubkey "$(cat $dir/intermediate/$common_name.authca.public.key)" \
--arg privkey "$(cat $dir/intermediate/private/$common_name.authca.private.key)" \
--arg cert $(cat $dir/intermediate/certs/$common_name.authca.crt) \
--arg kt $key_type_ssl \
". + {AuthCACertificateCreated: {publickey: $pubkey, privatekey: $privkey, certificate: $cert, key-type: $kt}}" \
>> "$eventlog"

# cleanup
unset org_publickey
unset org_privatekey
unset expires
unset org_name
unset orgid
unset common_name
unset country
unset region
unset locality
unset email
unset key_type_auth
unset key_type_encr
unset key_type_sign
unset key_type_ssl
unset dir
