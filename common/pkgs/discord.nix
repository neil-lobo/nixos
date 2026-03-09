{
  pkgs ? import <nixpkgs> { },
}:
pkgs.symlinkJoin {
  name = "discord";
  paths = [ pkgs.discord ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/discord --add-flags "--enable-blink-features=MiddleClickAutoscroll --disable-gpu"
    wrapProgram $out/bin/Discord --add-flags "--enable-blink-features=MiddleClickAutoscroll --disable-gpu"
  '';
}
