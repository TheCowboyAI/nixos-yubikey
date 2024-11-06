  function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  } 
  enabled="enable"

  if !$(ykman config list | grep -q 'FIDO2.*Enabled'); then
    ykman config $enabled fido2
  
    fidoevt=$( jq -n \
      --arg e $enabled \
    "{FidoEnableSet: {fido-enabled: $e}}"
    )
    eventlog "$fidoevt"
  fi
