{
  stdenv,
  lib,
  fetchFromGitHub ? lib.fetchFromGitHub,
  cmake,
  nemea-framework,
  fetchPypi,
  python3,
  pkg-config,
  ncurses,
  git,
  cacert,
  fuse3
}:

let
  nemea-pytrap = python3.pkgs.buildPythonPackage rec {
    pname = "nemea-pytrap";
    version = "0.17.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-Bpst1oU9ZbODgpF0oayjfT20wiheoG3HiLRWYyaqPa8=";
    };
    propagatedBuildInputs = with python3.pkgs; [ setuptools nemea-framework ];
  };

  pythonEnv = python3.withPackages (ps: [ nemea-pytrap ]);
in
stdenv.mkDerivation rec {
  pname = "Nemea Modules NG";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "CESNET";
    repo = "nemea-modules-ng";
    rev = "9d81cf1b59a8ba0cd357a1b0687d2d057106c471";
    hash = "sha256-nbjmifSCRMclKhaB7a9XXLLj/eu/yvKSkNoEYIRwk9c=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "add_subdirectory(pkg)" "# add_subdirectory(pkg)"
    substituteInPlace ./cmake/installation.cmake --replace-fail 'set(INSTALL_DIR_BIN "''${CMAKE_INSTALL_FULL_BINDIR}/nemea")' 'set(INSTALL_DIR_BIN "''${CMAKE_INSTALL_FULL_BINDIR}")'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_FULL_BINDIR=$out/bin"
  ];

  nativeBuildInputs = [ cmake pkg-config git cacert ];
  buildInputs = [  nemea-framework pythonEnv ncurses fuse3 ];

  meta = {
    description = "NEMEA Modules NG";
    homepage = "https://github.com/CESNET/nemea-modules-ng";
  };
}
