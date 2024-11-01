{ pkgs }:
pkgs.writeShellScriptBin "set-attributes" /*bash*/''
    function eventlog {
    local evt="$1"
    echo "$evt" >> "$EVENTLOG"
}

    export DEVICE=$(ykman list --serials)

    gpg --command-fd=0 --pinentry-mode=loopback --edit-card <<EOF
    admin
    login
    $P_IDENTITY
    $GPG_PIN
    quit
    EOF

    eventlog "{'yubikey-attributes-set':'$P_IDENTITY'}"
''
