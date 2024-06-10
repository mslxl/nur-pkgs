# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=ariang-native-git
{
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  imagemagick,
  makeWrapper,
  electron_29,
  lib,
  ...
} @ pkgs:
let
  pname = "ariang-native";
  version = "1.3.7";
in buildNpmPackage {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "mayswind";
      repo = "AriaNg-Native";
      rev = version;
      hash = "sha256-RRcL1qhv5v/QhateEaYjq3yNml9/UrZFja11PN4IXSE=";
    };

    npmDepsHash = "sha256-X/jMGPc1I1rTzozQCb5uVu/LokEAi2GSUxfH2cGM2NE=";
    makeCacheWritable = true;

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
    };
  
    nativeBuildInputs = [
      imagemagick
    ];
    buildInputs = [
      makeWrapper
    ];

    dontConfigure = true;
    dontNpmBuild = true;

    buildPhase = ''
      convert "assets/AriaNg.ico[0]" assets/ariang-native.png
      convert "assets/AriaNg_Metalink.ico[0]" assets/ariang-native-metalink.png
      convert "assets/AriaNg_Torrent.ico[0]" assets/ariang-native-torrent.png
    '';

    installPhase = ''
      mkdir -p $out/opt/ariang-native
      mkdir -p $out/share/icons/hicolor/256x256/apps/
      mkdir -p $out/share/mine/packages
      mkdir -p $out/share/applications

      mv assets/*.png $out/share/icons/hicolor/256x256/apps/
      mv * $out/opt/ariang-native/
      cp ${./ariang-native.xml} $out/share/mine/packages/ariang-native.xml
      cp ${./ariang-native.desktop} $out/share/applications/ariang-native.desktop

      sed -i "s@Exec=ariang-native@Exec=$out/bin/ariang-native@g" $out/share/applications/*.desktop

      makeWrapper ${electron_29}/bin/electron $out/bin/ariang-native \
        --argv0 "ariang-native" \
        --add-flags "$out/opt/ariang-native/main/main.js"
    '';

    meta = with lib; {
      description = "A better aria2 desktop frontend than AriaNg";
      homepage = "https://github.com/mayswind/AriaNg-Native";
      license = licenses.free;
      maintainers = with maintainers; [ mslxl ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "ariang-native";
    };
    
  }