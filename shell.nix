{ system ? builtins.currentSystem }:
(import ./release.nix {
  inherit system;
}).devShell
