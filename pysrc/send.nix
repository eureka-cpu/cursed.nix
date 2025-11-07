{ lib, python313Packages }:
let
  pname = "send";
  version = "0.0.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./send.py
    ];
  };
in
python313Packages.buildPythonApplication {
  inherit pname version src;
  format = "other";
  patchPhase = ''
    runHook prePatch
    patchShebangs send.py
    mkdir -p $out/bin
    chmod +x send.py
    cp send.py $out/bin
    runHook postPatch
  '';
}
