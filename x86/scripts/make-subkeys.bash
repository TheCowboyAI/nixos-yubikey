# generate Signature, Encryption and Authentication 
# Subkeys using the previously created Certify key 
jkey() {
  local key="$1" 
  jq -r ".\"${key}\"" <<< $secrets
}

secrets=$(<"~/secrets.json")
organization="$(jkey org.name)"
orgid="$(jkey org.id)"
passphrase="$(jkey org.certify_pass)"
fp="$(cat ~/certify-$orgid.fingerprint)"
publickey="$(cat ~/certify-$orgid.public.key)"
key_type_auth="$(jkey pgp.key_type_auth)"
key_type_encr="$(jkey pgp.key_type_encr)"
key_type_sign="$(jkey pgp.key_type_sign)"
expires="$(jkey pgp.expiration)"

gpg --batch --pinentry-mode=loopback --passphrase "$passphrase" \
  --quick-add-key "$fp" "$key_type_auth" auth "$expires"

gpg --batch --pinentry-mode=loopback --passphrase "$passphrase" \
  --quick-add-key "$fp" "$key_type_sign" sign "$expires"

gpg --batch --pinentry-mode=loopback --passphrase "$passphrase" \
  --quick-add-key "$fp" "$key_type_encr" encrypt "$expires"

# Save a copy of the Subkeys
gpg --output ~/$orgid-$publickey-subkeys.key \
    --batch --pinentry-mode=loopback --passphrase "$passphrase" \
    --armor --export-secret-subkeys $publickey

gpg --output ~/$orgid-$publickey.pub \
    --armor --export $publickey

jq -n \
  --arg org $orgid \
  --arg pubkey $(cat ~/$orgid-$publickey.pub) \
  --arg subkeys "$(jc $(cat ~/$publickey-subkeys.key))" \ 
  "{GpgSubkeysCreated: {org: $org, publickey: $pubkey, keys: $subkeys}"
>>>$eventlog
