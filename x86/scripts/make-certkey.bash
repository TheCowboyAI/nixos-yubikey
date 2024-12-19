source jkey

# set model
dir="/var/gpg"
passphrase="$(jkey org.certify_pass)"
org="$(jkey org.name)"
orgid="$(jkey org.id)"
key_type="$(jkey org.yubikey.pgp.key_type_auth)"
email="$(jkey org.email)"

### Create a Certify Key (always held offline)
identity="$org <$email> ($orgid)"

# create a new private key
gpg --batch \
    --passphrase "$passphrase" \
    --quick-generate-key "$identity" "$key_type" \
    cert never

# output it to file parts
publickey=$(gpg -k --with-colons "$identity" | awk -F: '/^pub:/ { print $5; exit }')
echo publickey > $dir/certify-$orgid.public.key

fingerprint=$(gpg -k --with-colons "$identity" | awk -F: '/^fpr:/ { print $10; exit }')
echo fingerprint > $dir/fp/certify-$orgid.fingerprint

gpg --output $dir/private/certify-$orgid.private.key \
    --batch \
    --pinentry-mode=loopback \
    --passphrase "$passphrase" \
    --armor \
    --export-secret-keys $publickey

jq -n \
    --arg org "$org" \
    --arg id "$orgid" \
    --arg pubkey "$publickey" \
    --arg fp "$fingerprint" \
    --arg privkey "$(cat $dir/private/certify-$orgid.private.key)" \
    --arg pass "$passphrase" \
    --arg ktype "$key_type" \
    '{GpgCertifyKeyCreated: {
        org: {name: $org, id: $id},
        key: {
            passphrase: $pass,
            keytype: $ktype,
            publickey: $pubkey,
            fingerprint: $fp,
            privatekey: $privkey
        }
    }}' >> "$eventlog"


#cleanup
unset secrets
unset passphrase
unset org
unset org_id
unset key_type
unset identity
unset email
unset dir
