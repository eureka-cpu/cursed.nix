{
  description = "A very basic flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
  };

  outputs =
    { self, nixpkgs }:
    let
      legacyPackages = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          (import ./overlay.nix)
        ];
      };
    in
    {
      packages = {
        x86_64-linux.default = legacyPackages.default;
        aarch64-multiplatform.default = legacyPackages.default-aarch64;
      };

      apps.x86_64-linux = {
        default = {
          type = "app";
          program = "${legacyPackages.default}/bin/run.sh";
        };
      };
    };
}
