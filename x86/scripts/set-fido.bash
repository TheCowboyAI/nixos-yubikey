jkey() {
  jq -r ".\"$1\"" <<< $secrets
}

secrets=$(<"~/secrets.json")
pin="$(jq -r .fido.pin)"
retry="$(jq -r .fido.retries)"

ykman fido access change-pin --new-pin "$pin"
ykman fido access set-pin-retries --pin-retries "$retry" --uv-retries "$retry" --pin "$pin"

jq -n \
    --arg pin "$pin" \
    "{FidoAccessSet: {pin: $pin, retries: $retry}}"
>> "$eventlog"