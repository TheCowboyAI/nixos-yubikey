jkey() {
  local key="$1" 
  jq -r ".\"${key}\"" <<< $secrets
}

secrets=$(<"~/secrets.json")