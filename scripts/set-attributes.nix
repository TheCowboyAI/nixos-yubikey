{ pkgs }:
pkgs.writeShellScriptBin "set-attributes" /*bash*/''
    function eventlog(evt) {echo evt >> $EVENTLOG}

  # TODO

    gpg --command-fd=0 --pinentry-mode=loopback --edit-card <<EOF
    admin
    login
    $P_IDENTITY
    $GPG_PIN
    quit
    EOF

    eventlog "{'yubikey-attributes-set':'$P_IDENTITY'}"
''
