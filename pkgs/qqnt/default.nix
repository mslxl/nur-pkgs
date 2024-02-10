{
  stdenv,
  fetchurl,
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
  pango,
  expat,
  cairo,
  ...
}:
let
  pname = "qqnt";
  version = "3.2.5";
  src = fetchurl {
    url = "https://dldir1.qq.com/qqfile/qq/QQNT/852276c1/linuxqq_3.2.5-21453_amd64.deb";
    hash = "sha256-6Qe4bP3q9RLEIJn9EfqqYaVTF8FRBNcjtVPl+zY7v5c=";
  };

  qqntBase = stdenv.mkDerivation {
    inherit pname version src;
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [ dpkg ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/opt $out/usr
      mv usr/share $out/usr
      mv opt/QQ $out/opt
      ln -s $out/opt/QQ/qq $out/bin/qq

      runHook postInstall
    '';
  };

  qqntFHS = buildFHSEnv {
    name = "qqnt-fhs";
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
      qq $*
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
    ln -s ${qqntFHS}/bin/qqnt-fhs $out/bin/qq
    cp -r ${qqntBase}/usr/share $out
    chmod -R u+w $out/share/applications/
    sed -i "s@/opt/QQ/qq@$out/bin/qq@g" $out/share/applications/*.desktop
    runHook postInstall
  '';

  meta = with lib; {
    description = "QQ9 轻松做自己";
    homepage = "https://im.qq.com/linuxqq/index.shtml";
    license = licenses.unfree;
    maintainers = with maintainers; [ mslxl ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "qq";
  };
}
