{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") { }
}:
let
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
    lua-language-server
    luaformatter
    rust-analyzer
    gopls
  ];
}
