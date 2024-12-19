# generate Signature, Encryption and Authentication 
# Subkeys using the previously created Certify key 
source jkey

dir="/var/gpg"
organization="$(jkey org.name)"
orgid="$(jkey org.id)"
passphrase="$(jkey org.certify_pass)"
fp="$(cat $dir/fp/certify-$orgid.fingerprint)"
publickey="$(cat $dir/certify-$orgid.public.key)"
key_type_auth="$(jkey org.yubikey.pgp.key_type_auth)"
key_type_encr="$(jkey org.yubikey.pgp.key_type_encr)"
key_type_sign="$(jkey org.yubikey.pgp.key_type_sign)"
expires="$(jkey pgp.expiration)"

gpg --batch \
  --pinentry-mode=loopback \
  --passphrase "$passphrase" \
  --quick-add-key "$fp" "$key_type_auth" auth "$expires"

gpg --batch \
  --pinentry-mode=loopback \
  --passphrase "$passphrase" \
  --quick-add-key "$fp" "$key_type_sign" sign "$expires"

gpg --batch \
  --pinentry-mode=loopback \
  --passphrase "$passphrase" \
  --quick-add-key "$fp" "$key_type_encr" encrypt "$expires"

# Save a copy of the Subkeys
gpg --output $dir/private/$orgid-$publickey-subkeys.private.key \
    --batch \
    --pinentry-mode=loopback \
    --passphrase "$passphrase" \
    --armor --export-secret-subkeys $publickey

gpg --output $dir/$orgid-$publickey.public.key \
    --armor --export $publickey

jq -n \
  --arg org $orgid \
  --arg pubkey $(cat $dir/$orgid-$publickey.public.key) \
  --arg subkeys "$(jc $(cat $dir/private/$orgid-$publickey-subkeys.private.key))" \ 
  "{GpgSubkeysCreated: {org: $org, publickey: $pubkey, keys: $subkeys}" \
>>$eventlog
