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
        arch = archs.${system};
        version = "1.7.3";

        src_urls = {
          darwin-universal = {
            url = "https://github.com/crystal-lang/crystal/releases/download/1.7.3/crystal-1.7.3-1-darwin-universal.tar.gz";
            hash = "sha256-o1RI9aJJCBv967F3DgA0z/Hqq7qDiMAjGWKQvZ0myRQ=";
          };
          x86_64-linux = {
            url = "https://github.com/crystal-lang/crystal/releases/download/1.7.3/crystal-1.7.3-1-linux-x86_64.tar.gz";
            hash = "sha256-wyMXNZSMj0X19aBbmd4BI2o+QIiI6yjHq3B9qpux/Zw=";
          };
        };

        src = pkgs.fetchurl src_urls.${arch};

        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          crystal = pkgs.callPackage ./crystal {
            inherit src;
          };

          default = crystal;
        };
      });
}
