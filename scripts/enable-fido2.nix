{ pkgs }:
let
in
pkgs.writeShellScriptBin "enable-fido2" /*bash*/''
  function eventlog(evt) {echo evt >> $EVENTLOG} 

  if !(ykman config list | grep -q 'FIDO2.*Enabled'); then
      ykman config enable fido2
      eventlog "{'fido-enabled': true}"
  fi
''
