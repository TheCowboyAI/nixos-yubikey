jkey() {
  jq -r ".\"$1\"" <<< $secrets
}

secrets=$(<"~/secrets.json")
pin="$(jkey fido.pin)"
retry="$(jkey fido.retries)"

  # Change PIV PIN and PUK
  ykman piv change-pin --pin "$DEFAULT_PIN" --new-pin "$PIV_PIN" 
  ykman piv change-puk --puk "$DEFAULT_PUK" --new-puk "$PIV_PUK" 
  ykman piv change-management-key --algorithm $PIV_ALG --management-key $MGMT_KEY_OLD -new-management-key $MGMT_KEY 

xfer-certs

