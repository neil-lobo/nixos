{
  pkgs ? import <nixpkgs> { },
  thermalZone
}:

let
    version = "4.0";

    derivation = pkgs.stdenv.mkDerivation {
        pname = "burn2cool";
        inherit version;

        src = pkgs.fetchFromGitHub {
            owner = "DiabloPower";
            repo = "burn2cool";
            tag = "v${version}";
            hash = "sha256-VojD5sPcsUa45BmRL0A+keUb2xexoACFJfg2gH1MYzA=";
        };

        nativeBuildInputs = [
            pkgs.unixtools.xxd
        ];

        buildInputs = [
            pkgs.ncurses
        ];

        installPhase = ''
        mkdir -p $out/bin
        cp cpu_throttle $out/bin
        cp cpu_throttle_tui $out/bin
        cp cpu_throttle_ctl $out/bin
        '';
    };
in
{
    inherit derivation;
    systemd = {
        enable = true;
        description = "burn2cool daemon";

        serviceConfig = {
            User = "root";
            ExecStart = "${derivation}/bin/cpu_throttle --thermal-zone ${builtins.toString thermalZone} --web-port 8086";
            Restart = "no";
        };
    };
}
