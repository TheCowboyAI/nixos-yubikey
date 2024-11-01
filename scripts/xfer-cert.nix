{ pkgs }:
pkgs.writeShellScriptBin "xfer-certs" /*bash*/''
  function eventlog(evt) {echo evt >> $EVENTLOG}

  eventlog "{'openssl-rootca-transferred':{'name':'$COMMON_NAME'}}"

  eventlog "{'openssl-wildcard-transferred':{'name':'*.$COMMON_NAME'}}"
  
  eventlog "{'openssl-client-transferred':{'name':'$X_COMMON_NAME'}}"

''
