{ lib, python313Packages }:
let
  pname = "serve";
  version = "0.0.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./serve.py
    ];
  };
in
python313Packages.buildPythonApplication {
  inherit pname version src;
  format = "other";
  patchPhase = ''
    runHook prePatch
    mkdir -p $out/bin
    chmod +x serve.py
    cp serve.py $out/bin
    runHook postPatch
  '';
}
