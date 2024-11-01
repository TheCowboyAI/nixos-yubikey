{ pkgs }:
pkgs.writeShellScriptBin "set-oauth-password" /*bash*/''
  function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

  ykman oauth access change-password -n $OAUTH_PASSWORD
  eventlog "{'set-oauth-password':'$OAUTH_PASSWORD'}"
''
