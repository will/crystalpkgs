{ stdenv
, lib
, src
, substituteAll
  # build deps
, llvm
, crystal_prebuilt
, tzdata
  # install deps
, installShellFiles
, makeWrapper
, which
  # crystal common deps
, boehmgc
, gmp
, libevent
, libiconv
, libxml2
, libyaml
, clang
, openssl
, pcre2
, pkg-config
, zlib
, libffi
  # useful
, shards
  # options
, release ? false
}:
stdenv.mkDerivation rec {
  name = "crystal";
  inherit src;
  inherit (stdenv) isDarwin;

  enableParallelBuilding = true;
  strictDeps = true;
  outputs = [ "out" "lib" "bin" ];

  nativeBuildInputs = [ makeWrapper installShellFiles crystal_prebuilt ];

  buildInputs = [ libffi boehmgc gmp libevent libxml2 libyaml openssl pcre2 zlib ]
    ++ lib.optionals isDarwin [ libiconv ];

  patches = [
    (substituteAll {
      src = ./tzdata.patch;
      inherit tzdata;
    })
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace 'CRYSTAL_CONFIG_BUILD_COMMIT :=' 'CRYSTAL_CONFIG_BUILD_COMMIT ?=' \
      --replace 'SOURCE_DATE_EPOCH :=' 'SOURCE_DATE_EPOCH ?='
  '';

  dontConfigure = true;

  LLVM_CONFIG = "${llvm.dev}/bin/llvm-config";
  CRYSTAL_CONFIG_TARGET = stdenv.targetPlatform.config;
  CRYSTAL_CONFIG_BUILD_COMMIT = src.rev;
  SOURCE_DATE_EPOCH = "0";
  buildPhase = ''
    export CRYSTAL_CACHE_DIR=$(mktemp -d)
    make interpreter=1 ${lib.optionalString release " release=1"}
    rm -rf $CRYSTAL_CACHE_DIR
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 ${shards}/bin/shards $bin/bin/shards
    install -Dm755 .build/crystal $bin/bin/crystal
    wrapProgram $bin/bin/crystal \
       --suffix PATH : ${lib.makeBinPath [ pkg-config clang which ]} \
       --suffix CRYSTAL_PATH : lib:$lib/crystal \
       --suffix CRYSTAL_LIBRARY_PATH : ${ lib.makeLibraryPath (buildInputs) } \
       --suffix PKG_CONFIG_PATH : ${openssl.dev}/lib/pkgconfig \
       --suffix CRYSTAL_OPTS : "-Duse_pcre2" \

    install -dm755 $lib/crystal
    cp -r src/* $lib/crystal/

    mkdir -p $out
    ln -s $bin/bin $out/bin
    ln -s $lib $out/lib

    installShellCompletion etc/completion.fish etc/completion.bash etc/completion.zsh

    runHook postInstall
  '';

  dontStrip = true;
}
