let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  luapkgs = with pkgs.luaPackages; [ luasocket ];
  pypkgs = pkgs.python313.withPackages (pypkgs: with pypkgs; [
    black
    python-lsp-server
    python-lsp-ruff
  ]);
in
pkgs.mkShell {
  name = "cursed-shell";
  nativeBuildInputs = with pkgs; [
    luapkgs
    pypkgs
    cargo
    go
  ];
  packages = with pkgs; [
    npins
    lua-language-server
    luaformatter
    rust-analyzer
    gopls
  ];
}
