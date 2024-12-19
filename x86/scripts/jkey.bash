jkey() {
  jq -r "$1" <<< $secrets
}
