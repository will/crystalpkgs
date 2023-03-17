{ stdenv
, src
, lib
  # deps
, boehmgc
, libevent
, libiconv
, libxml2
, libyaml
, llvmPackages
, makeWrapper
, openssl
, pcre
, pkg-config
, which
, zlib
}:
stdenv.mkDerivation rec {
  name = "crystal";
  inherit src;

  nativeBuildInputs = [ makeWrapper which pkg-config llvmPackages.llvm ];

  strictDeps = true;
  outputs = [ "out" "lib" "bin" ];

  buildInputs = [
    boehmgc
    libevent
    libxml2
    libyaml
    openssl
    pcre
    zlib
  ] ++ lib.optionals stdenv.isDarwin [ libiconv ];

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall

    install -Dm755 ./embedded/bin/shards $bin/bin/shards
    install -Dm755 ./embedded/bin/crystal $bin/bin/crystal
    wrapProgram $bin/bin/crystal \
       --suffix PATH : ${lib.makeBinPath [ pkg-config llvmPackages.clang which ]} \
       --suffix CRYSTAL_PATH : lib:$lib/crystal \
       --suffix CRYSTAL_LIBRARY_PATH : ${ lib.makeLibraryPath (buildInputs) } \
       --suffix PKG_CONFIG_PATH : ${openssl.dev}/lib/pkgconfig
    install -dm755 $lib/crystal
    cp -r src/* $lib/crystal/

    mkdir -p $out
    ln -s $bin/bin $out/bin
    ln -s $lib $out/lib

    runHook postInstall
  '';

  dontStrip = true;
}



