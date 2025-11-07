{
  rustPlatform,
  lib,
}:

rustPlatform.buildRustPackage {
    pname = "rustsrc";
    version = "1.0.0";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./Cargo.lock
        ./Cargo.toml
        ./rustsrc/main.rs
      ];
    };

    cargoLock = {
        lockFile = ./Cargo.lock;
    };

}