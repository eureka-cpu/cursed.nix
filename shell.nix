let
  sources = import ./npins;
  pkgs = import sources.nixpkgs {
    overlays = [
      (import ./overlay.nix)
    ];
  };
in
pkgs.mkShell {
  inputsFrom = [
    pkgs.default
    pkgs.rustserve
    pkgs.pythonsend
    pkgs.gosend
    pkgs.luasend
    pkgs.luaserve
    pkgs.goserve
    pkgs.pythonserve
  ];
}
