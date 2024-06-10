{
  stdenv,
  fetchurl,
  fetchFromGitHub,
  dpkg,
  lib,
  glib,
  nss,
  nspr,
  cups,
  dbus,
  libdrm,
  xorg,
  mesa,
  buildFHSEnv,
  gtk3,
  libnotify,
  libxkbcommon,
  libGL,
  pango,
  expat,
  cairo,
  ...
}:
let
  pname = "liteloader-qqnt";
  version = "1.1.1";
  qqVersion = "3.2.9.24568";

  qqSrc = fetchurl {
    url = "https://dldir1.qq.com/qqfile/qq/QQNT/a663aa83/linuxqq_3.2.9-24568_amd64.deb";
    hash = "sha256-DcQWwep4p4aWUAoBNQ9Ge1QBiCxk6BhcziTDSHmRpgY=";
  };
  liteloaderSrc = fetchFromGitHub {
    owner = "LiteLoaderQQNT";
    repo = "LiteLoaderQQNT";
    rev = version;
    hash = "sha256-tq8QCOEbchfr3TJBDAZJhvjYPmQ996MyruBYgPdHTA8=";
  };

  liteloaderBase = stdenv.mkDerivation {
    inherit pname version;
    src = liteloaderSrc;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/LiteLoader
    mv ./* $out/opt/LiteLoader

    runHook postInstall
    '';
  };


  qqntBase = stdenv.mkDerivation {
    pname = "qqnt";
    version = qqVersion;
    src = qqSrc;

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [ dpkg ];
    buildInputs = [ liteloaderBase ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/opt $out/usr
      mv usr/share $out/usr
      mv opt/QQ $out/opt
      ln -s $out/opt/QQ/qq $out/bin/qq


      chmod u+w $out/opt/QQ/resources/app/app_launcher/index.js
      chmod -R u+rw $out/opt/QQ/resources/app/application
      cp ${liteloaderSrc}/src/preload.js $out/opt/QQ/resources/app/application/preload.js
      sed -i "1 i require(\"${liteloaderBase}/opt/LiteLoader\");" $out/opt/QQ/resources/app/app_launcher/index.js

      runHook postInstall
    '';
  };


  liteloaderFHS = buildFHSEnv {
    name = "liteloader-qqnt-fhs";
    targetPkgs = pkgs: (with pkgs; [
      qqntBase
      udev
      alsa-lib
      glib
      nss
      nspr
      atk
      cups
      dbus
      gtk3
      libdrm
      mesa
      libnotify
      libxkbcommon
      pango
      cairo
      expat
      libuuid
      libkrb5
      libgcrypt
      libGL
      libGL.dev
    ]) ++ (with pkgs.xorg; [
      libX11
      libXcursor
      libXrandr
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libxcb
    ]);
    runScript = ''
    sh -c "mkdir -p ~/.config/LiteLoader; if [ ! -f '~/.config/LiteLoader/config.json' ]; then cp ${liteloaderSrc}/config.json ~/.config/LiteLoader; fi; LITELOADERQQNT_PROFILE='$HOME/.config/LiteLoader' qq"
    '';
  };
in stdenv.mkDerivation {
  inherit pname version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/opt/QQ
    ln -s ${liteloaderFHS}/bin/liteloader-qqnt-fhs $out/bin/liteloader-qqnt
    cp -r ${qqntBase}/usr/share $out
    chmod -R u+w $out/share/applications/
    sed -i "s@/opt/QQ/qq@$out/bin/liteloader-qqnt@g" $out/share/applications/*.desktop
    sed -i "s@Name=.*@Name=QQ (with LiteLoader)@" $out/share/applications/*.desktop
    sed -i "s@Icon=/usr/@Icon=$out/@" $out/share/applications/*.desktop
    runHook postInstall
  '';

  meta = with lib; {
    description = "轻量, 简洁, 开源的 QQNT 插件加载器";
    homepage = "https://github.com/LiteLoaderQQNT/LiteLoaderQQNT";
    license = licenses.unfree;
    maintainers = with maintainers; [ mslxl ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "liteloader-qqnt";
  };
}
