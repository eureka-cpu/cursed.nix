{ system ? builtins.currentSystem
, projectRootFile ? "release.nix"
}:
(import ./release.nix {
  inherit system projectRootFile;
}).devShell
