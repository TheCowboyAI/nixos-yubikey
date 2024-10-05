{ pkgs }:
# Set a single yubikey all at once
# DO NOT use this to link Yubikeys
pkgs.writeShellScriptBin "set-yubikey" ''
  
''
