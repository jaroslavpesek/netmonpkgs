{
  stdenv,
  lib,
  fetchFromGitHub ? lib.fetchFromGitHub,
  cmake,
  libfds,
  docutils,
  libxml2,
  rdkafka,
  zlib,
  lz4,
  nemea-framework,
  git,
  cacert,
  protobuf
}:

stdenv.mkDerivation rec {
  pname = "ipfixcol2";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "jaroslavpesek";
    repo = "ipfixcol2";
    #tag = "v${version}";
    rev = "95e34dce62693b26fac725bd6ddf14a1f12e03ee";
    hash = "sha256-sPOFlXqpcT8Y8JCvGJdGxmw4gDhvFH5hIZ2TPFeEF38=";
  };

  nativeBuildInputs = [ cmake git cacert ];
  buildInputs = [ libfds docutils libxml2 rdkafka zlib lz4 nemea-framework protobuf ];

  postInstall = ''
    cd ../extra_plugins/output/unirec
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_C_FLAGS="$CFLAGS -Wno-error=implicit-function-declaration" -DCMAKE_INSTALL_LIBDIR=lib
    make
    make install
    cd ../../clickhouse
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_C_FLAGS="$CFLAGS -Wno-error=implicit-function-declaration" -DCMAKE_INSTALL_LIBDIR=lib
    make
    echo "Make install cliuckhouse"
    make install
    cd ../../protobuf-kafka
    mkdir build
    cd build
    echo "Building Protobuf-Kafka plugin"
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_C_FLAGS="$CFLAGS -Wno-error=implicit-function-declaration" -DCMAKE_INSTALL_LIBDIR=lib
    make
    echo "Make install protobuf-kafka"
    make install

  '';

  meta = {
    description = "Flexible, high-performance NetFlow v5/v9 and IPFIX flow data collector designed to be extensible by plugins";
    homepage = "https://github.com/CESNET/ipfixcol2";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
