{ lib, luaPackages }:
let
  pname = "serve";
  version = "0.0.0-1";
  rockspecFilename = ./${pname}-${version}.rockspec;
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      rockspecFilename
      ./serve.lua
    ];
  };
in
luaPackages.buildLuaApplication {
  inherit pname version src;
  buildInputs = with luaPackages; [ luasocket ];
  propagatedBuildInputs = with luaPackages; [ luasocket ];
  patchPhase = ''
    runHook prePatch
    mkdir -p $out/bin
    chmod +x serve.lua
    cp serve.lua $out/bin
    runHook postPatch
  '';
}
