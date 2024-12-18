    function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  }

  ykman oauth access change-password -n $OAUTH_PASSWORD

  oauthevt=$( jq -n \
    --arg pwd "$OAUTH_PASSWORD" \
    "{OauthPasswordSet: {oauth-password: $pwd}}"
  )
  eventlog $fidoevt