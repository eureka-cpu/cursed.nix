let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };

  run = pkgs.runCommand "run-script" { } ''
    mkdir -p $out/bin
    cp ${./run.sh} $out/bin/run.sh
    chmod +x $out/bin/run.sh
  '';

  lib = pkgs.lib;
in
{
  default = run;

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

    installPhase = ''
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

    installPhase = ''
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
    vendorHash = null;
  };
}
