let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };

  gosend = pkgs.callPackage ./gosrc/send.nix { };
  goserve = pkgs.callPackage ./gosrc/serve.nix { inherit pysend; };
  luasend = pkgs.callPackage ./luasrc/send.nix { };
  luaserve = pkgs.callPackage ./luasrc/serve.nix { inherit gosend; };
  pysend = pkgs.callPackage ./pysrc/send.nix { };
  pyserve = pkgs.callPackage ./pysrc/serve.nix { inherit luasend; };
in
{
  inherit
    gosend
    goserve
    luasend
    luaserve
    pysend
    pyserve
    ;
  curse = pkgs.callPackage ./rustsrc { };
}
