##### cursed.nix

# OH NO, YOU"VE BEEN CURSED

Contained in this repo lies a cursed piece of ancient software written by the elders.

You have accidentally unleased it upon the world.

Your final test to graduate from acolytes and rid yourself of this blight is to...

- Package the software using vanilla nix. Keep in mind the naming convention of each package in `.github/workflows/checks.yml`.

  1. Create a `shell.nix` file and missing packages/deps and developer tools. Fix any compile errors.
  2. Use the `default.nix` and `release.nix` pattern with `npins` for sources to package the project. Don't forget to keep your repo tidy along the way!
  3. Use your knowledge of the different flavors of `mkDerivation`, eg. writers and language specific builders. Do _not_ use IFD (Import From Derivation), use only FOD (Fixed Output Derivation) when applicable
  4. Patch shebangs and substitute hardcoded paths for nix-store paths.
  5. Add an `aarch64-linux` cross compiled derivation, and static derivation for the default package. BONUS: Try to add them for the other packages too.
  6. Create an `overlay.nix` for the default, cross and static packages. Use the `symlinkJoin` functionality to create a linked package of the default packages.
  7. Update the `shell.nix` file to use the inputs directly from the derivations. Remove any unnecessary packages/deps, but be sure the dev env still works.

- Add flake support.

  8. Add `packages`/`apps` and use IFD to vendor dependencies where possible. Do not use `flake-utils` or `flake-parts`. **Include support for more than one system.**
  9. Add and configure a `formatter`.
  10. Add any remaining `checks` at the derivation level, such as formatting and linting. Add a `nixosTest` integration test, and include a failure case in the script. Test it using `nix flake check`.
  11. Create `nixosModules` and add binding options for each command line feature and environment variable. Configure their default
  packages using `mkDefault` and force the port to be a specific port. Modules should be made for both `packages` and `services`.
  12. Create `nixosConfigurations` and use the modules you defined. Look at `https://github.com/NixOS/nixpkgs/tree/master/nixos/modules`
  and select a module to include, then configure its options in a new module; title it apropriately. Enable the firewall, configure
  a module that enables port forwarding from a VM and reuse the `config` to idiomatically enable ports in the firewall if their services
  are also enabled.
  13. Add an _interactive_ `nixosTest` node for debugging.
  14. BONUS: Go through the nixcademy article to setup nixos containers in the slides and setup container configurations.
  Deploy the configurations to them, and ensure they are working.
