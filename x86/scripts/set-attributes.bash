jkey() {
  jq -r ".\"$1\"" <<< $secrets
}

secrets=$(<"~/secrets.json")
yubikey_id=$(ykman list --serials)

id="$(jq -r .org.name) ($(jq -r .org.id)) <$(jq -r .org.email)>"

gpg --command-fd=0 --pinentry-mode=loopback --edit-card <<EOF
admin
name
$id
$gpg_pin
quit
EOF
  
jq -n \
    --arg sn "$yubikey_id" \
    --arg name "$id" \
    "{YubikeyAttributesSet:{yubikey: $sn, name: $name}}" \
>> "$eventlog"