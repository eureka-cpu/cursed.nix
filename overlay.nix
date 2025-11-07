final: prev:
let
  pkgsStatic = prev.pkgsStatic;
  aarch64Pkgs = prev.pkgsCross.aarch64-multiplatform;
in
{
  gosend = prev.callPackage ./gosrc/send.nix { };
  goserve = prev.callPackage ./gosrc/serve.nix { };

  luasend = prev.callPackage ./luasrc/send.nix { };
  luaserve = prev.callPackage ./luasrc/serve.nix { };

  pysend = prev.callPackage ./pysrc/send.nix { };
  pyserve = prev.callPackage ./pysrc/serve.nix { };

  curse = prev.callPackage ./rustsrc { };
  curse-static = pkgsStatic.callPackage ./rustsrc { };
  curse-aarch64 = aarch64Pkgs.callPackage ./rustsrc { };

  curse-bundle = prev.symlinkJoin {
    name = "curse-bundle";
    paths = with final; [
      gosend
      goserve
      luasend
      luaserve
      pysend
      pyserve
      curse
    ];
  };
}
