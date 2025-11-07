{ lib, buildGoModule }:
let
  pname = "serve";
  version = "0.0.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./go.mod
      ./cmd/serve/main.go
    ];
  };
in
buildGoModule {
  inherit pname version src;
  vendorHash = null;
  doCheck = false;
  buildPhase = ''
    runHook preBuild
    go build cmd/serve/main.go
    mkdir -p $out/bin
    mv main $out/bin/serve.go
    runHook postBuild
  '';
}
