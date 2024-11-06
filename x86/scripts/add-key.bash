sn=$(get-serials)

read -p "Do you want to add this Yubikey?: $sn: " -n1 ok

if [[ "$ok" = "Y" || "$ok" = "y" ]]; then
  export YUBIKEY_ID="$sn"
  echo "$sn\n">>yubikeys
else
  # indicate it failed
  exit 1 
fi
