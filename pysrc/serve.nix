{ lib, python313Packages, luasend }:
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
    patchShebangs serve.py
    substituteInPlace serve.py \
      --replace-fail '"../luasrc/send.lua"' '"${luasend}/bin/send.lua"'
    cat serve.py
    mkdir -p $out/bin
    chmod +x serve.py
    cp serve.py $out/bin
    runHook postPatch
  '';
}
