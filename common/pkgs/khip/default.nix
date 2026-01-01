{
  pkgs ? import <nixpkgs> { },
}:
let
  model_32_kw = pkgs.fetchurl {
    url = "https://cdn.discordapp.com/assets/krisp_browser_models/v1.0.11_1/model_32.kw";
    sha256 = "sha256-TEldeJycd1BppD3q3XPgtuRgy1XuKr4sJbtdyq9/KNU=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "khip";
  version = "0.4";
  src = fetchTarball {
    url = "https://codeberg.org/khip/khip/archive/v0.4.tar.gz";
    sha256 = "sha256:1sz6hf5sfvvbvz244xgfkh0janz3bvy4hz1mlws83vrz1s1ndkv2";
  };
  patches = [
    ./patches/fix-meson.patch
  ];

  postPatch = ''
    cp ${model_32_kw} model_32.kw
  '';

  nativeBuildInputs = with pkgs; [
    ninja
    meson
    curl
    python3
    pkg-config
  ];

  buildInputs = with pkgs; [
    fftwFloat
    openblas
    ladspa-sdk
    libsamplerate
  ];
}
