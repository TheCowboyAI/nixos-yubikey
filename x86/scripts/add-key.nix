{ pkgs }:
pkgs.writeShellScriptBin "add-key" /*bash*/''
  local sn=$(get-serials)
  
  read -p "Do you want to add this Yubikey?: $sn: " ok
  
  if [[ "$ok" = "Y" || "$ok" = "y" ]]; then
    export YUBIKEY_ID="$sn"
    export YUBIKEYS+="$sn"
  else
    # indicate it failed
    exit 1 
  fi
''
