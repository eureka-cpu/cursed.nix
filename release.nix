let
  sources = import ./npins;
  legacyPackages = import sources.nixpkgs {
    system = "x86_64-linux";
    overlays = [
      (import ./overlay.nix)
    ];
  };
in
{
  default = legacyPackages.symlinkJoin {
    name = "runstuff";
    paths = [
      legacyPackages.default
      legacyPackages.default-static
      legacyPackages.default-aarch64
    ];
    postBuild = ''
      ls
    '';
  };
}
