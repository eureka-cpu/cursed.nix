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
      npins
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
