let
  sources = import ./npins;
  pkgs = import sources.nixpkgs {
    overlays = [
      (import ./overlay.nix)
    ];
  };
in
{
  inherit (pkgs)
    gosend
    goserve
    luasend
    luaserve
    pysend
    pyserve
    curse
    curse-bundle
    ;
  inherit (pkgs)
    curse-static
    curse-aarch64
    ;
}
