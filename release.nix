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
}:
let
  pkgs = import nixpkgs {
    inherit system;
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
    ] ++ (with pkgs.python313Packages; [
      black
      python-lsp-server
      python-lsp-ruff
    ]);
  };
}
