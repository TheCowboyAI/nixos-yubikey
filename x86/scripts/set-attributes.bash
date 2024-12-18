jkey() {
  jq -r ".\"$1\"" <<< $secrets
}

secrets=$(<"~/secrets.json")
yubikey_id=$(ykman list --serials)

id="$(jkey org.name) ($(jkey org.id)) <$(jkey org.email)>"

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