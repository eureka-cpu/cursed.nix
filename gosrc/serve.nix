{ lib, buildGoModule, pysend }:
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
  patchPhase = ''
    runHook prePatch
    substituteInPlace cmd/serve/main.go \
      --replace-fail '"../pysrc/send.py"' '"${pysend}/bin/send.py"'
    cat cmd/serve/main.go
    runHook postPatch
  '';
  buildPhase = ''
    runHook preBuild
    go build cmd/serve/main.go
    mkdir -p $out/bin
    mv main $out/bin/serve.go
    runHook postBuild
  '';
}
