final: prev: {

  exorcise = final.callPackage
    ({ stdenv, lib, curse, serve-go, serve-lua, serve-py }:
      stdenv.mkDerivation {
        pname = "exorcise";
        version = "13.13.13";

        src = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.unions [
            ./run.sh
            ./luasrc/chunk1.bin
            ./pysrc/chunk2.bin
            ./gosrc/chunk3.bin
          ];
        };

        propogatedBuildInputs = [ curse serve-go serve-lua serve-py ];

        installPhase = ''
          substituteInPlace ./run.sh \
            --replace-fail "./serve.lua" "${serve-lua}/bin/serve.lua" \
            --replace-fail "./serve.py" "${serve-py}/bin/serve.py" \
            --replace-fail "./serve" "${serve-go}/bin/serve-go" \
            --replace-fail "\"chunk1.bin\"" "\"$out/share/exorcism_supplies/chunk1.bin\"" \
            --replace-fail "\"chunk2.bin\"" "\"$out/share/exorcism_supplies/chunk2.bin\"" \
            --replace-fail "\"chunk3.bin\"" "\"$out/share/exorcism_supplies/chunk3.bin\""

          mkdir -p $out/bin
          mv ./run.sh $out/bin/exorcise.sh
          mkdir -p $out/share/exorcism_supplies
          mv ./luasrc/chunk1.bin $out/share/exorcism_supplies/chunk1.bin
          mv ./pysrc/chunk2.bin $out/share/exorcism_supplies/chunk2.bin
          mv ./gosrc/chunk3.bin $out/share/exorcism_supplies/chunk3.bin
        '';
      }) { };

  curse = final.callPackage ({ stdenv, lib, rustPlatform }:
    rustPlatform.buildRustPackage {
      pname = "curse";
      version = "13.13.13";

      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./rustsrc/main.rs
          ./Cargo.lock
          ./Cargo.toml
        ];
      };

      cargoLock.lockFile = ./Cargo.lock;
    }) { };

  send-go = let pname = "send-go";
  in final.callPackage ({ buildGoModule, lib, go }:
    buildGoModule {
      inherit pname;
      version = "13.13.13";

      vendorHash = null;

      src = lib.fileset.toSource {
        root = ./gosrc;
        fileset = lib.fileset.unions [ ./gosrc/send.go ./gosrc/go.mod ];
      };

      buildInputs = [ go ];

      # Define the build phase
      buildPhase = ''
        go build -o ${pname} .
      '';

      # Define the install phase
      installPhase = ''
        mkdir -p $out/bin
        mv ${pname} $out/bin/${pname}
      '';
    }) { };

  serve-go = let pname = "serve-go";
  in final.callPackage ({ buildGoModule, lib, go, send-py }:
    buildGoModule {
      inherit pname;
      version = "13.13.13";

      vendorHash = null;

      src = lib.fileset.toSource {
        root = ./gosrc;
        fileset = lib.fileset.unions [ ./gosrc/serve.go ./gosrc/go.mod ];
      };

      buildInputs = [ go ];

      propogatedBuildInputs = [ send-py ];

      patchPhase = ''
        substituteInPlace ./serve.go \
          --replace-fail "../pysrc/send.py" "${send-py}/bin/send.py"
      '';

      # Define the build phase
      buildPhase = ''
        go build -o ${pname} .
      '';

      # Define the install phase
      installPhase = ''
        mkdir -p $out/bin
        mv ${pname} $out/bin/${pname}
      '';
    }) { };

  send-lua = let
    pname = "send";
    lua-env = final.lua.withPackages (ps: with ps; [ luasocket ]);
  in final.callPackage ({ luaPackages, lib, lua }:
    luaPackages.buildLuaApplication {
      inherit pname;
      version = "0.0.0-1";

      src = lib.fileset.toSource {
        root = ./luasrc;
        fileset = lib.fileset.unions [
          ./luasrc/send-0.0.0-1.rockspec
          ./luasrc/send.lua
        ];
      };

      buildInputs = [ lua-env ];
      propogatedBuildInputs = [ lua-env ];

      postInstall = ''
        mkdir -p $out/bin
        cp ./send.lua $out/bin/send.lua
        patchShebangs $out/bin
      '';
    }) { };

  serve-lua = let
    pname = "serve";
    lua-env = final.lua.withPackages (ps: with ps; [ luasocket ]);
  in final.callPackage ({ luaPackages, lua, lib, send-go }:
    luaPackages.buildLuaApplication {
      inherit pname;
      version = "0.0.0-1";

      src = lib.fileset.toSource {
        root = ./luasrc;
        fileset = lib.fileset.unions [
          ./luasrc/serve-0.0.0-1.rockspec
          ./luasrc/serve.lua
        ];
      };

      buildInputs = [ lua-env ];
      propogatedBuildInputs = [ lua-env send-go ];

      postInstall = ''
        substituteInPlace ./serve.lua \
          --replace-fail "../gosrc/send" "${send-go}/bin/send-go"

        mkdir -p $out/bin
        mv ./serve.lua $out/bin/serve.lua
        patchShebangs $out/bin
      '';
    }) { lua = lua-env; };

  send-py = let pname = "send-py";
  in final.callPackage ({ python313Packages, lib, send-go }:
    python313Packages.buildPythonPackage {
      inherit pname;
      version = "13.13.13";
      pyproject = false;

      src = lib.fileset.toSource {
        root = ./pysrc;
        fileset = lib.fileset.unions [ ./pysrc/send.py ];
      };

      postInstall = ''
        mkdir -p $out/bin
        mv ./send.py $out/bin/send.py
        patchShebangs $out/bin
      '';
    }) { };

  serve-py = let pname = "serve-py";
  in final.callPackage ({ python313Packages, lib, lua, send-lua }:
    python313Packages.buildPythonPackage {
      inherit pname;
      version = "13.13.13";
      pyproject = false;

      src = lib.fileset.toSource {
        root = ./pysrc;
        fileset = lib.fileset.unions [ ./pysrc/serve.py ];
      };

      propogatedBuildInputs = [ send-lua ];

      postInstall = ''
        substituteInPlace ./serve.py \
          --replace-fail "../luasrc/send.lua" "${send-lua}/bin/send.lua"

        mkdir -p $out/bin
        mv ./serve.py $out/bin/serve.py
        patchShebangs $out/bin
      '';
    }) { };
}
