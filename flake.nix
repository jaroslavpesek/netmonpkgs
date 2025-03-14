{
  description = "NETwork MONitoring PacKaGeS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... }:
  let
    systems = [ "x86_64-linux" ];

    mkPkgs = callPackage: let pkg = {
      libfds = callPackage ./pkgs/libfds/default.nix { };
      nemea-framework = callPackage ./pkgs/nemea-framework/default.nix { };
      ipfixcol2 = callPackage ./pkgs/ipfixcol2/default.nix {
        libfds = pkg.libfds;
        nemea-framework = pkg.nemea-framework;
      };
      nemea-modules = callPackage ./pkgs/nemea-modules/default.nix {
        nemea-framework = pkg.nemea-framework;
      };
    }; in pkg;
  in {
    packages = builtins.listToAttrs (map (system: {
      name = system;
      value = let
        pkgs = import nixpkgs { inherit system; };
      in mkPkgs pkgs.callPackage;
    }) systems);

    overlays = {
      default = final: prev: mkPkgs final.callPackage;
    };

    nixosModules = {
      ipfixcol2 = import ./modules/ipfixcol2.nix;
      general-nemea-module = import ./modules/general-nemea-module.nix;
    };
  };
}