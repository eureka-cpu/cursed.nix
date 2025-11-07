{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    eachSupportedSystem = nixpkgs.lib.genAttrs supportedSystems;
    overlay = import ./overlay.nix;
  in
  {
    packages = eachSupportedSystem (system: let
        pkgs = import nixpkgs { inherit system; overlays = [overlay]; };
      in {
        inherit (pkgs) exorcism curse send-go serve-go send-py serve-py send-lua serve-lua;
        default = pkgs.exorcism;
    });

    apps = eachSupportedSystem (system: let
        pkgs = import nixpkgs { inherit system; overlays = [overlay]; };
      in {
        exorcise = {
          type = "app";
          program = "${pkgs.exorcism}/bin/exorcise.sh";
        };
    });
  };
}