{
    python313Packages,
    python313,
    lib,
}:

python313Packages.buildPythonApplication {
    pname = "python-send";
    version = "1.0.0";
    format = "other";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./send.py
      ];
    };
}