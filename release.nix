let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  pkgsStatic = pkgs.pkgsStatic;
  aarch64Pkgs = pkgs.pkgsCross.aarch64-multiplatform;

  gosend = pkgs.callPackage ./gosrc/send.nix { };
  goserve = pkgs.callPackage ./gosrc/serve.nix { inherit pysend; };
  luasend = pkgs.callPackage ./luasrc/send.nix { };
  luaserve = pkgs.callPackage ./luasrc/serve.nix { inherit gosend; };
  pysend = pkgs.callPackage ./pysrc/send.nix { };
  pyserve = pkgs.callPackage ./pysrc/serve.nix { inherit luasend; };
  curse = pkgs.callPackage ./rustsrc { };

  curse-static = pkgsStatic.callPackage ./rustsrc { };
  curse-aarch64 = aarch64Pkgs.callPackage ./rustsrc { };
in
{
  inherit
    gosend
    goserve
    luasend
    luaserve
    pysend
    pyserve
    curse
    ;
  inherit
    curse-static
    curse-aarch64
    ;
}
