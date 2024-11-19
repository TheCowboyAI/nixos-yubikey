# if there is more than one, ask to use only one

sn=$(get-serials)



# see if the serial is already registered
if [[ "$sn" = $YUBIKEY_ID ]]; then
  read -p "Do you want to add this Yubikey?: $sn: " -n1 ok
  if [[ "$ok" = "Y" || "$ok" = "y" ]]; then
    export YUBIKEY_ID="$sn"
    echo "$sn\n">>yubikeys

    jq -c \
    --arg org "$ORG_NAME" \
    --arg domain "$COMMON_NAME" \
    --arg id "$O_IDENTITY" \
    --arg sn $(ykman list --serials) \
    ". + {YubikeyAdded: {serial: $sn, organization: $org, domain: $domain, identity: $id}}" \
    "$EVENTLOG" >> "$EVENTLOG"
  fi
else
  echo "Yubikey already registered: $sn"
fi