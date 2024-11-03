{ pkgs }:
pkgs.writeShellScriptBin "xfer-certs" /*bash*/''
    function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  }

    # there isn't anything special for ssl tranfers, that is only for gpg getting in the way.
    # there is room for more certs, just repeat for more certs and incerment up to 95

    ykman piv certificates import --subject 82 -m "$MGMT_KEY $COMMON_NAME".crt

    rootcaevt=$( jq -n \
      --arg cn "$COMMON_NAME" \
      --arg id "$YUBIKEY_ID" \
      "{SslRootCaTransferred: {yubikey: $id, name: $cn}}" 
    )
    eventlog "$rootcaevt"

    ykman piv certificates import --subject 83 -m "$MGMT" wildcard."$COMMON_NAME".crt

    wildcardevt=$( jq -n \
      --arg cn "$COMMON_NAME" \
      --arg id "$YUBIKEY_ID" \
      "{SslWildcardTransferred: {yubikey: $id, name: $cn}}" 
    )
    eventlog "$wildcardevt"
  
    ykman piv certificates import --subject 84 -m "$MGMT" sslclient."$COMMON_NAME".crt

    clientevt=$( jq -n \
      --arg cn "$X_COMMON_NAME" \
      --arg id "$YUBIKEY_ID" \
      "{SslClientTransferred: {yubikey: $id, name: $cn}}" 
    )
    eventlog "$clientevt"

    # detect any supplied certs
    slotnum=85
    for cert in ./"$COMMON_NAME".*.crt; do  
      local key="${cert::-3}pem"
      ykman piv certificates import --subject "$slotnum" -m "$MGMT" "$cert"

      clientevt=$( jq -n \
        --arg id "$YUBIKEY_ID" \
        --arg privkey "$(cat $key)" \
        --arg cert "$(cat $cert)" \
        --arg slot "$slotnum" \
        "{SslCertificateTransferred: {yubikey: $id, private-key: $privkey, certificate: $crt, slot: $slot}}" 
      )

      eventlog "$clientevt"

      ((slotnum++))
    done
''
