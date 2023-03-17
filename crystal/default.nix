{ stdenv
, src
}:
stdenv.mkDerivation {
  name = "crystal";

  inherit src;

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out
    cp -r bin embedded src $out
  '';
}
