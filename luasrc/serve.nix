{
    lua,
    luaPackages,
    lib,
}:

luaPackages.buildLuaApplication {
    pname = "send";
    version = "0.0.0-1";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./send.lua
        ./send-0.0.0-1.rockspec
      ];
    };

    nativeBuildInputs = [ 
      luaPackages.luasocket
    ];
    buildInputs = [ 
      luaPackages.luasocket
    ];
    propagatedBuildInputs = [ 
      luaPackages.luasocket
    ];
}