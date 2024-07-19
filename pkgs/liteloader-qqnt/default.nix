{
  stdenv,
  fetchurl,
  fetchFromGitHub,
  callPackage,
  ...
} @ pkgs:
let
  pname = "liteloader-qqnt";
  liteloaderVersion = "1.1.2";

  qqnt = pkgs.callPackage ../qqnt {};

  qqntPatched = stdenv.mkDerivation {
    pname = "qq-patched";
    version = "${liteloaderVersion}-${qqnt.qq-base.version}";
    src = fetchFromGitHub {
      owner = "LiteLoaderQQNT";
      repo = "LiteLoaderQQNT";
      rev = liteloaderVersion;
      hash = "sha256-o9NLTSFPRMm+wdve60nF8BCthS/ZjTmheBvBFxE/YC8=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
    runHook preInstall
    mkdir -p $out
    mkdir -p $out/opt/LiteLoader

    cp -r ${qqnt.qq-base}/* $out/
    mv ./* $out/opt/LiteLoader

    chmod u+w $out/opt/QQ/resources/app/app_launcher/index.js
    chmod -R u+w $out/opt/QQ/resources/app/app_launcher/
    chmod -R u+rw $out/opt/QQ/resources/app/application

    cp $out/opt/LiteLoader/src/preload.js $out/opt/QQ/resources/app/application/preload.js
    sed -i "1 i require(\"$out/opt/LiteLoader\");" $out/opt/QQ/resources/app/app_launcher/index.js

    runHook postInstall
    '';
  };


in qqnt.bundle {
  base = qqntPatched;
  pname = pname;
  appName = "QQ (with LiteLoaderQQNT)";

  preStart = ''
    [ ! -d ~/.config/LiteLoader ] && mkdir -p ~/.config/LiteLoader
    export LITELOADERQQNT_PROFILE="$HOME/.config/LiteLoader"
  '';
}
