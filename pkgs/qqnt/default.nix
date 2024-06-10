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
  libGL,
  pango,
  expat,
  cairo,
  writeShellScript,
  ...
}:
let
  baseVersion = "3.2.9.24568";
  baseSrc = fetchurl {
    url = "https://dldir1.qq.com/qqfile/qq/QQNT/a663aa83/linuxqq_3.2.9-24568_amd64.deb";
    hash = "sha256-DcQWwep4p4aWUAoBNQ9Ge1QBiCxk6BhcziTDSHmRpgY=";
  };
in rec {
    qq-base = stdenv.mkDerivation {
        version = baseVersion;
        src = baseSrc;
        pname = "qqnt";
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
    bundle = ({base ? qq-base, preStart ? "", pname ? "qq", appName ? "QQ", version ? base.version}:
        let
            fhs = buildFHSEnv {
                name = "${pname}-fhs";
                targetPkgs = pkgs: (with pkgs; [
                    base
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
                runScript =  "${writeShellScript "launch-qqnt-base" ''
                    ${preStart}
                    qq $*
                ''} $*";
            };
        in stdenv.mkDerivation {
            inherit pname version;

            dontUnpack = true;
            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
                runHook preInstall
                mkdir -p $out/bin
                ln -s ${fhs}/bin/${pname}-fhs $out/bin/${pname}
                cp -r ${base}/usr/share $out
                chmod -R u+w $out/share/applications/
                sed -i "s@/opt/QQ/qq@$out/bin/${pname}@g" $out/share/applications/*.desktop
                sed -i "s@Name=.*@Name=${appName}@" $out/share/applications/*.desktop
                sed -i "s@Icon=/usr/@Icon=$out/@" $out/share/applications/*.desktop
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
    );

    fhs = bundle {};
}