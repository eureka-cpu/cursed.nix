final: prev: 

{
    cursed-rust = final.callPackage ./rustsrc.nix { };
    py-send = final.callPackage ./pysrc/send.nix { };
    py-serve = final.callPackage ./pysrc/serve.nix { };
    go-send = final.callPackage ./gosrc/send.nix { };
    go-serve = final.callPackage ./gosrc/serve.nix { };
    lua-send = final.callPackage ./luasrc/send.nix { };
    lua-serve = final.callPackage ./luasrc/serve.nix { };
}