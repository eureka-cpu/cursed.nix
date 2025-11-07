let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
in
{
  gosend = pkgs.callPackage ./gosrc/send.nix { };
  goserve = pkgs.callPackage ./gosrc/serve.nix { };
  luasend = pkgs.callPackage ./luasrc/send.nix { };
  luaserve = pkgs.callPackage ./luasrc/serve.nix { };
  pysend = pkgs.callPackage ./pysrc/send.nix { };
  pyserve = pkgs.callPackage ./pysrc/serve.nix { };
  curse = pkgs.callPackage ./rustsrc { };
}
