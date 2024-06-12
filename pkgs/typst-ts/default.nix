{
    stdenv,
    fetchurl,
    lib,
    autoPatchelfHook,
    ...
}:
stdenv.mkDerivation rec {
    pname = "typst.ts";
    version = "0.4.1";

    dontConfigure = true;
    dontBuild = true;

    src = fetchTarball {
        url = "https://github.com/Myriad-Dreamin/typst.ts/releases/download/v${version}/typst-ts-x86_64-unknown-linux-gnu.tar.gz";
        sha256 = "0c5ha81yaslydnzinkrcd4a8kyd42gm05b5v6dyadgkd6rv1yi05";
    };

    nativeBuildInputs = [ autoPatchelfHook ];

    buildInputs = [stdenv.cc.cc.lib];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mv bin/* $out/bin

      runHook postInstall
    '';
  }