{
    buildGoModule,
    lib,
}:

buildGoModule {
    pname = "go_send";
    version = "1.0.0";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./send.go
        ./go.mod
      ];
    };

    vendorHash = null;
}