{ pkgs }:
pkgs.writeShellScriptBin "test-fido" /*bash*/''
  # test that the fido settings are usable... piv, puk, retries, auth
''
