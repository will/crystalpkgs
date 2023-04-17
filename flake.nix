{
  description = "Crystal";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    let
      sys = flake-utils.lib.system;
    in
    flake-utils.lib.eachSystem [ sys.aarch64-darwin sys.x86_64-darwin sys.x86_64-linux ] (system:
      let
        version = "1.8.0";
        src_urls = {
          darwin-universal = {
            url = "https://github.com/crystal-lang/crystal/releases/download/${version}/crystal-${version}-1-darwin-universal.tar.gz";
            hash = "sha256-CKbciHPOU68bpgMEWhRf7+I/gDxrraorTX4CxmbTQtA=";
          };
          linux-x86_64 = {
            url = "https://github.com/crystal-lang/crystal/releases/download/${version}/crystal-${version}-1-linux-x86_64.tar.gz";
            hash = "sha256-AAsbMB/IH8cGpndYIEwgHLYgwQj6CzLZfrEmXdf5QXc=";
          };
        };

        archs = {
          x86_64-darwin = "darwin-universal";
          aarch64-darwin = "darwin-universal";
          x86_64-linux = "linux-x86_64";
        };
        arch = archs.${system};
        src = pkgs.fetchurl src_urls.${arch};

        gh_src = pkgs.fetchFromGitHub {
          owner = "crystal-lang";
          repo = "crystal";
          rev = version;
          hash = "sha256-L1SUeuifXBlwyL60an2ndsAuLhZ3RMBKxYrKygzVBI8";
        };

        pkgs = import nixpkgs { inherit system; };
        llvmPackages = pkgs.llvmPackages_15;
      in
      {
        packages = rec {
          crystal_prebuilt = pkgs.callPackage ./crystal/prebuilt.nix { inherit src version llvmPackages; };
          shards = pkgs.callPackage ./crystal/shards.nix { crystal = crystal_prebuilt; inherit (pkgs) fetchFromGitHub; };
          crystal = pkgs.callPackage ./crystal {
            inherit crystal_prebuilt shards version llvmPackages;
            src = gh_src;
          };
          extraWrapped = pkgs.callPackage ./crystal/extra-wrapped.nix { inherit crystal; buildInputs = [];};
          crystal_dev = crystal.override { release = false; };
          default = crystal;
        };
      });
}
