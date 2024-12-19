# generate Signature, Encryption and Authentication 
# Subkeys using the previously created Certify key 


dir="/var/gpg"
organization="$(jq -r .org.name <<< $secrets)"
orgid="$(jq -r .org.id <<< $secrets)"
passphrase="$(jq -r .org.certify_pass <<< $secrets)"
fp="$(cat $dir/fp/certify-$orgid.fingerprint)"
publickey="$(cat $dir/certify-$orgid.public.key)"
key_type_auth="$(jq -r .org.yubikey.pgp.key_type_auth <<< $secrets)"
key_type_encr="$(jq -r .org.yubikey.pgp.key_type_encr <<< $secrets)"
key_type_sign="$(jq -r .org.yubikey.pgp.key_type_sign <<< $secrets)"
expires="$(jq -r .pgp.expiration <<< $secrets)"

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
