{ pkgs }:
pkgs.writeShellScriptBin "enable-piv-touch" /*bash*/''
    function eventlog {
      local evt="$1"
      echo "$evt" >> "$EVENTLOG"
  }

    ykman piv access set-touch-policy always --management-key $MGMT_KEY 9a
    pivtouchevt=$( jq -n \
      -- arg enabled true \
      "{PivTouchPolicySet: {piv-touch: $enabled}}"
    )
    eventlog "$pivtouchevt"
''
