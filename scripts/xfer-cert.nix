{ pkgs }:
pkgs.writeShellScriptBin "xfer-certs" /*bash*/''
  function eventlog(evt) {echo evt >> $EVENTLOG}

  rootcaevt=$( jq -n \
    --arg cn "$COMMON_NAME" \
    '{openssl-rootca-transferred: {name: $cn}}' 
  )
  eventlog rootcaevt

  wildcardevt=$( jq -n \
    --arg cn "$COMMON_NAME" \
    '{openssl-wildcard-transferred: {name: $cn}}' 
  )
  eventlog wildcardevt
  
  clientevt=$( jq -n \
    --arg cn "$X_COMMON_NAME" \
    '{openssl-client-transferred: {name: $cn}}' 
  )
  eventlog clientevt
''
