{ lib, rustPlatform }:
let
  root = ../.;
  manifest = (root + "/Cargo.toml");
  lockFile = (root + "/Cargo.lock");
  toml = lib.importTOML manifest;
  pname = toml.package.name;
  version = toml.package.version;
  src =
    lib.fileset.toSource {
      inherit root;
      fileset = lib.fileset.unions [
        manifest
        lockFile
        (root + "/rustsrc/main.rs")
      ];
    };
in
rustPlatform.buildRustPackage {
  inherit pname version src;
  cargoDeps = rustPlatform.importCargoLock { inherit lockFile; };
  doCheck = false;
}
