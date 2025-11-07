final: prev:

let
  sources = import ./npins;
  pkgs = import sources.nixpkgs {
    system = "x86_64-linux";
  };

  lib = pkgs.lib;

  rustserve = pkgs.rustPlatform.buildRustPackage {
    pname = "rust-serve";
    version = "1.0.0";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./rustsrc
        ./Cargo.lock
        ./Cargo.toml
        ./rust-toolchain.toml
      ];
    };
    cargoHash = "sha256-z0R8SqyBrOFQ17N8WkAXgtsokF4i57OyLdUuk6dRAHY=";
  };

  pythonsend = pkgs.stdenv.mkDerivation {
    pname = "python-send";
    version = "1.0.0";

    src = ./pysrc;

    patchPhase = ''
      runHook prePatch
      patchShebangs send.py
      runHook postPatch
    '';

    buildPhase = ''
      mkdir -p $out/bin
      cp send.py $out/bin/send.py
    '';
  };

  gosend = pkgs.buildGoModule {
    pname = "go-send";
    name = "go-send";
    src = lib.fileset.toSource {
      root = ./gosrc;
      fileset = lib.fileset.unions [
        ./gosrc/go.mod
        ./gosrc/send.go
      ];
    };
    vendorHash = null;
  };

  luasend = pkgs.stdenv.mkDerivation {
    pname = "lua-send";
    version = "1.0.0";

    src = ./luasrc;

    buildInputs = [
      pkgs.lua
      pkgs.luaPackages.luasocket
    ];

    propagatedBuildInputs = [ pkgs.luaPackages.luasocket ];

    patchPhase = ''
      runHook prePatch

      patchShebangs send.lua

      runHook postPatch
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp send.lua $out/bin/send.lua

      # Create a wrapper script
      cat > $out/bin/send <<EOF
      #!/bin/sh
      export LUA_PATH="${pkgs.luaPackages.luasocket}/share/lua/${pkgs.lua.luaversion}/?.lua;;"
      export LUA_CPATH="${pkgs.luaPackages.luasocket}/lib/lua/${pkgs.lua.luaversion}/?.so;;"
      exec ${pkgs.lua}/bin/lua $out/bin/send.lua "\$@"
      EOF

      chmod +x $out/bin/send
      runHook postInstall
    '';
  };

  luaserve = pkgs.stdenv.mkDerivation {
    pname = "lua-serve";
    version = "1.0.0";

    src = ./luasrc;

    buildInputs = [
      pkgs.lua
      pkgs.luaPackages.luasocket
    ];

    propagatedBuildInputs = [ pkgs.luaPackages.luasocket ];

    patchPhase = ''
      runHook prePatch
      substituteInPlace serve.lua --replace-fail "../gosrc/send " "${gosend}/bin/sendserver "
      patchShebangs serve.lua
      runHook postPatch
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp serve.lua $out/bin/serve.lua

      # Create a wrapper script
      cat > $out/bin/serve <<EOF
      #!/bin/sh
      export LUA_PATH="${pkgs.luaPackages.luasocket}/share/lua/${pkgs.lua.luaversion}/?.lua;;"
      export LUA_CPATH="${pkgs.luaPackages.luasocket}/lib/lua/${pkgs.lua.luaversion}/?.so;;"
      exec ${pkgs.lua}/bin/lua $out/bin/serve.lua "\$@"
      EOF

      chmod +x $out/bin/serve
      runHook postInstall
    '';
  };

  goserve = pkgs.buildGoModule {
    pname = "go-serve";
    name = "go-serve";
    src = lib.fileset.toSource {
      root = ./gosrc;
      fileset = lib.fileset.unions [
        ./gosrc/go.mod
        ./gosrc/serve.go
      ];
    };

    patchPhase = ''
      runHook prePatch
      substituteInPlace serve.go --replace-fail "../pysrc/send.py" "${pythonsend}/bin/send.py"
      runHook postPatch
    '';
    vendorHash = null;
  };

  pythonserve = pkgs.stdenv.mkDerivation {
    pname = "python-serve";
    version = "1.0.0";

    src = ./pysrc;

    patchPhase = ''
      runHook prePatch
      substituteInPlace serve.py --replace-fail "../luasrc/send.lua" "${luasend}/bin/send"
      patchShebangs serve.py
      runHook postPatch
    '';

    buildPhase = ''
      mkdir -p $out/bin
      cp serve.py $out/bin/serve.py
    '';
  };

  runFunc =
    { stdenv, name_suffix }:
    stdenv.mkDerivation {
      pname = "run-script-${name_suffix}";
      version = "1.0.0";

      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./run.sh
          ./gosrc/chunk3.bin
          ./luasrc/chunk1.bin
          ./pysrc/chunk2.bin
        ];
      };

      buildInputs = [
        rustserve
        goserve
        luaserve
        pythonserve
      ];

      patchPhase = ''
        runHook prePatch
        substituteInPlace run.sh \
          --replace-fail "cd ./gosrc" "" \
          --replace-fail "cd ./luasrc" "" \
          --replace-fail "cd ./pysrc" "" \
          --replace-fail "./target/debug/curse &" "${rustserve}/bin/curse &" \
          --replace-fail "./serve \"chunk3.bin\"" "${goserve}/bin/sendserver $out/data/chunk3.bin" \
          --replace-fail "./serve.lua \"chunk1.bin\"" "${luaserve}/bin/serve $out/data/chunk1.bin" \
          --replace-fail "./serve.py \"chunk2.bin\"" "${pythonserve}/bin/serve.py $out/data/chunk2.bin"
        runHook postPatch
      '';

      buildPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/data
        cp run.sh $out/bin/run${name_suffix}.sh

        cp gosrc/chunk3.bin $out/data/chunk3.bin
        cp luasrc/chunk1.bin $out/data/chunk1.bin
        cp pysrc/chunk2.bin $out/data/chunk2.bin

        chmod +x $out/bin/run${name_suffix}.sh
      '';
    };

in
{
  default = final.callPackage runFunc { name_suffix = ""; };
  default-static = final.pkgsStatic.callPackage runFunc { name_suffix = "static"; };
  default-aarch64 = final.pkgsCross.aarch64-multiplatform.callPackage runFunc {
    name_suffix = "aarch64";
  };
}
