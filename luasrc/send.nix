{
    lua,
    luaPackages,
    lib,
}:

luaPackages.buildLuaApplication {
    pname = "serve";
    version = "0.0.0-1";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./serve.lua
        ./serve-0.0.0-1.rockspec
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