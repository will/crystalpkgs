{ stdenv
, src
, lib
  # deps
, installShellFiles
, boehmgc
, libevent
, libiconv
, libxml2
, libyaml
, llvmPackages
, makeWrapper
, openssl
, pcre2
, pkg-config
, which
, zlib
}:
stdenv.mkDerivation rec {
  name = "crystal";
  inherit src;

  nativeBuildInputs = [ makeWrapper installShellFiles ];

  strictDeps = true;
  outputs = [ "out" "lib" "bin" ];

  buildInputs = [
    boehmgc
    libevent
    libxml2
    libyaml
    openssl
    pcre2
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
       --suffix PKG_CONFIG_PATH : ${openssl.dev}/lib/pkgconfig \
       --suffix CRYSTAL_OPTS : "-Duse_pcre2"

    install -dm755 $lib/crystal
    cp -r src/* $lib/crystal/

    installShellCompletion --cmd crystal etc/completion.*

    mkdir -p $out
    ln -s $bin/bin $out/bin
    ln -s $lib $out/lib

    runHook postInstall
  '';

  dontStrip = true;
}



