# sanity check
checkvars

# set model
passphrase="$(jkey org.certify_pass)"
org="$(jkey org.name)"
orgid="$(jkey org.id)"
key_type="$(jkey pgp.key_type_auth)"

# validate or die
# List of required variables
required_vars=("passphrase" "org" "orgid" "key_type")

# Check each variable
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set."
        exit 1
    fi
done

### Create a Certify Key (always held offline)
# since this an automated process,
# Identity should be acme@common_name, see: https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment

# create a new private key
gpg --batch \
    --passphrase "$passphrase" \
    --quick-generate-key "$org" "$key_type" \
    cert never

# output it to file parts
publickey=$(gpg -k --with-colons "$org" | awk -F: '/^pub:/ { print $5; exit }')
echo publickey > ~/certify-$orgid.public.key

fingerprint=$(gpg -k --with-colons "$org" | awk -F: '/^fpr:/ { print $10; exit }')
echo fingerprint > ~/certify-$orgid.fingerprint

gpg --output ~/certify-$orgid.private.key \
    --batch --pinentry-mode=loopback --passphrase "$passphrase" \
    --armor --export-secret-keys $publickey

jq -n \
    --arg org "$org" \
    --arg id "$orgid" \
    --arg pubkey "$publickey" \
    --arg fp "$fingerprint" \
    --arg privkey "$(cat ~/certify-$orgid.private.key)" \
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
