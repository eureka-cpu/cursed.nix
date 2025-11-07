{
  description = "A very cursed flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, treefmt }:
    let
      defaultSystems = [ "x86_64-linux" "aarch64-linux" ];
      eachSystem = f: nixpkgs.lib.genAttrs defaultSystems (system:
        let
          release = import ./release.nix {
            inherit system nixpkgs;
            treefmt = treefmt.lib;
          };
        in
        f system release release.legacyPackages);
    in
    {
      overlays.default = import ./overlay.nix;

      legacyPackages = eachSystem (_: _: pkgs: pkgs);

      packages = eachSystem (_: _: pkgs:
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
        });

      apps = eachSystem (_: _: pkgs:
        let
          type = "app";
          sendMeta = {
            meta.description = "Send chunks of data over TCP to the specified address";
          };
          serveMeta = {
            meta.description = "Continually serve chunks of data over TCP to the specified address";
          };
        in
        {
          gosend = {
            inherit type;
            program = "${pkgs.gosend}/bin/send.go";
          } // sendMeta;
          goserve = {
            inherit type;
            program = "${pkgs.goserve}/bin/serve.go";
          } // serveMeta;
          luasend = {
            inherit type;
            program = "${pkgs.luasend}/bin/send.lua";
          } // sendMeta;
          luaserve = {
            inherit type;
            program = "${pkgs.luaserve}/bin/serve.lua";
          } // serveMeta;
          pysend = {
            inherit type;
            program = "${pkgs.pysend}/bin/send.py";
          } // sendMeta;
          pyserve = {
            inherit type;
            program = "${pkgs.pyserve}/bin/serve.py";
          } // serveMeta;
          curse = {
            inherit type;
            program = "${pkgs.curse}/bin/curse";
            meta.description = "A webserver waiting to receive chunks to display to the specified address";
          };
        });

      devShells = eachSystem (system: _: _: {
        default = import ./shell.nix { inherit system; projectRootFile = "flake.nix"; };
      });

      formatter = eachSystem (_: release: pkgs: treefmt.lib.mkWrapper pkgs (release.formattingOptions "flake.nix"));
    };
}
