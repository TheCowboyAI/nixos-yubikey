{ lib, config, pkgs, ... }:
let
  name = "add-key";
  cfg = config.${name};
  script = pkgs.writeShellScriptBin "${name}" /*bash*/''
    sn=$(get-serials)

    read n 1 -p "Do you want to add this Yubikey?: $sn: " ok
  
    if [[ "$ok" = "Y" || "$ok" = "y" ]]; then
      export YUBIKEY_ID="$sn"
      echo "$sn\n">>yubikeys
    else
      # indicate it failed
      exit 1 
    fi
  '';
in
{
  options.add-key.enable = lib.mkEnableOption "Enable ${name}";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      script
    ];
  };
}
