{ lib, buildGoModule }:
let
  pname = "send";
  version = "0.0.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./go.mod
      ./cmd/send/main.go
    ];
  };
in
buildGoModule {
  inherit pname version src;
  vendorHash = null;
  doCheck = false;
  buildPhase = ''
    runHook preBuild
    go build cmd/send/main.go
    mkdir -p $out/bin
    mv main $out/bin/send.go
    runHook postBuild
  '';
}
