{ pkgs }:
pkgs.writeShellScriptBin "edit-env" /*bash*/''
  sn=$(get-serials)
  
  read -p "Do you want to add this Yubikey?: $sn" ok
  
  if [[ "$ok" = "Y" || "$ok" = "y" ]]; then
    YUBIKEY_ID=$sn
    YUBIKEYS=("${YUBIKEYS[@]}" $sn)
  else
    exit 1
  fi
''
