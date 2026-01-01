pkgs:
pkgs.symlinkJoin {
  name = "google-chrome";
  paths = [ pkgs.google-chrome ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/google-chrome-stable --add-flags "--enable-blink-features=MiddleClickAutoscroll"
  '';
}
