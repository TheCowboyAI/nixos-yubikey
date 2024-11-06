{ lib, config, pkgs, ... }:
let
  name = "set-piv-pins";
  cfg = config.${name};
  path = builtins.toString ./${name}.bash;
  script = pkgs.writeShellScriptBin "${name}" (builtins.readFile path);
in
{
  options.${name}.enable = lib.mkEnableOption "Enable ${name}";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      script
    ];
  };
}
