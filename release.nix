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
        cursed-rust
        go-serve
        go-send
        py-serve
        py-send
        lua-serve
        lua-send
        ;

    devShell = pkgs.mkShell {
        inputsFrom = with pkgs; [
          cursed-rust
          go-serve
          go-send
          py-serve
          py-send
          lua-serve
          lua-send
        ];
        shellHook = ''
            echo "Welcome to the dev-shell of cursed.nix"
            export PS1="cursed.nix > "
        '';
    };
}