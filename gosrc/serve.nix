{
    buildGoModule,
    lib,
    go,
    py-send,
}:

buildGoModule {
    pname = "serve";
    version = "1.0.0";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./serve.go
        ./go.mod
      ];
    };

    nativeBuildInputs = [ 
      go
    ];

    vendorHash = null;

    postPatch = ''
        substituteInPlace serve.go --replace-fail '"../pysrc/send.py"' '"${py-send}/bin/send.lua"'
    '';
}