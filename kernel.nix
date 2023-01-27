{pkgs, stdenv, fetchurl, config, ...}:
let
in
  {
    nixpkgs.overlays = [];

    boot = {
      extraModulePackages = [];
      # kernelPackages = pkgs.linuxPackages_6_2;
    };
  }
