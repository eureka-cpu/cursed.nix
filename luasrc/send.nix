{ lib, luaPackages }:
let
  pname = "send";
  version = "0.0.0-1";
  rockspecFilename = ./${pname}-${version}.rockspec;
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      rockspecFilename
      ./send.lua
    ];
  };
in
luaPackages.buildLuaApplication {
  inherit pname version src;
  buildInputs = with luaPackages; [ luasocket ];
  propagatedBuildInputs = with luaPackages; [ luasocket ];
  patchPhase = ''
    runHook prePatch
    patchShebangs send.lua
    mkdir -p $out/bin
    chmod +x send.lua
    cp send.lua $out/bin
    runHook postPatch
  '';
}
