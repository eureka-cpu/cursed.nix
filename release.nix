let
  inherit (builtins)
    currentSystem
    fromJSON
    readFile
    ;

  sources = fromJSON (readFile ./flake.lock);
  fetchFromSources = name:
    with sources.nodes.${name}.locked; {
      inherit rev;
      outPath = fetchTarball {
        url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        sha256 = narHash;
      };
    };
in
# Reuse sources from the `flake.lock` in the root if we are not supplied them.
{ system ? currentSystem
, nixpkgs ? fetchFromSources "nixpkgs"
, treefmt ? import (fetchFromSources "treefmt")
, projectRootFile ? "release.nix"
}:
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      (import ./overlay.nix)
    ];
  };
  formattingOptions = projectRootFile: {
    inherit projectRootFile;
    programs = {
      nixpkgs-fmt.enable = true;
      gofmt.enable = true;
      black.enable = true;
      rustfmt.enable = true;
      taplo.enable = true;
    };
  };
  treefmtEval = treefmt.evalModule pkgs (formattingOptions projectRootFile);
  formatter = treefmtEval.config.build.wrapper;
  checks = {
    format = treefmtEval.config.build.check ./.;
  };
in
{
  inherit
    formattingOptions
    formatter
    checks
    ;
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

  legacyPackages = pkgs;

  devShell = pkgs.mkShell {
    name = "cursed-shell";
    inputsFrom = with pkgs; [
      gosend
      goserve
      luasend
      luaserve
      pysend
      pyserve
      curse
    ];
    packages = with pkgs; [
      lua-language-server
      luaformatter
      rust-analyzer
      gopls
      formatter
    ] ++ (with pkgs.python313Packages; [
      python-lsp-server
      python-lsp-ruff
    ]);
  };
}
