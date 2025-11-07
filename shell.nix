let
  sources = import ./npins;
  rust_overlay = import sources.rust-overlay;
  pkgs = import sources.nixpkgs {
    overlays = [
      rust_overlay
    ];
  };

  rust = pkgs.rust-bin.nightly.latest.default.override { };
in
pkgs.mkShell {
  packages = [
    pkgs.npins
    rust
    pkgs.go
    pkgs.lua
    pkgs.luaPackages.luasocket
    pkgs.python313
  ];

  RUSTFLAGS = "--cfg procmacro2_semver_exempt -Z allow-features=edition2024";
}
