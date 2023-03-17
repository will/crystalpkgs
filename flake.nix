{
  description = "Crystal";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        archs = {
          x86_64-darwin = "darwin-universial";
          aarch64-darwin = "darwin-universal";
          x86_64-linux = "linux-amd64";
          aarch64-linux = "linux-arm64";
        };

        src = pkgs.fetchurl {
          url = "https://github.com/crystal-lang/crystal/releases/download/1.7.3/crystal-1.7.3-1-darwin-universal.tar.gz";
          hash = "sha256-o1RI9aJJCBv967F3DgA0z/Hqq7qDiMAjGWKQvZ0myRQ=";
        };

        arch = archs.${system};

        version = "1.7.3";

        pkgs = import nixpkgs { inherit system; };

      in
      {
        packages = rec {
          crystal = pkgs.callPackage ./crystal {
            inherit src;
            stdenv = pkgs.stdenv;
          };

          default = crystal;
        };
      });
}
