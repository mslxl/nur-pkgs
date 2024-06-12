# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  dida365 = pkgs.callPackage ./pkgs/dida365 { };
  apifox = pkgs.callPackage ./pkgs/apifox { };
  qqnt = (pkgs.callPackage ./pkgs/qqnt { }).fhs;
  liteloader-qqnt = pkgs.callPackage ./pkgs/liteloader-qqnt { };
  ariang-native = pkgs.callPackage ./pkgs/ariang-native { };
  typst-ts = pkgs.callPackage ./pkgs/typst-ts { };
  # ...
}
