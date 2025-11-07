let
  sources = (import ./npins);
  pkgs = (import sources.nixpkgs) { overlays = [ (import ./overlay.nix) ]; };
  lua = pkgs.lua.withPackages (ps: with ps; [ luasocket ]);
in {
  inherit (pkgs) exorcise curse send-go serve-go send-lua serve-lua send-py serve-py;

  devShell = pkgs.mkShell {
    nativeBuildInputs = with pkgs; [ npins rustc cargo python313 lua luarocks-nix curse send-go serve-go send-lua serve-lua send-py serve-py ];
    inputsFrom = with pkgs; [ exorcise curse send-go serve-go send-py serve-py send-lua serve-lua ];
    shellHook = ''
      echo "Welcome to the cursed shell"
      export PS1="incantation > "
    '';
  };
}
