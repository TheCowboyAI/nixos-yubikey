{ lib, config, pkgs, ... }:
let
  name = "scriptname";
  cfg = config.${name};
  script = pkgs.writeShellScriptBin "${name}" /*bash*/''
    # do bash things
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
