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
  default = legacyPackages.default;
  default-static = legacyPackages.default-static;
  default-aarch64 = legacyPackages.default-aarch64;
}
