{ pkgs }:
pkgs.writeShellScriptBin "test-yubikey" /*bash*/''
  # test that piv is usable... encr, sign, auth
''
