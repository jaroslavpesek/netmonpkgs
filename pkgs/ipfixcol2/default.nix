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
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "jaroslavpesek";
    repo = "ipfixcol2";
    #tag = "v${version}";
    rev = "81e91f34f78b6a76aefe18f8b7e7ff965ae5db34";
    hash = "sha256-SnGpYsoltttS0Pz9bjQ8Es3JJouZ/41vqJzmMAif9qo=";
  };

  nativeBuildInputs = [ cmake git cacert ];
  buildInputs = [ libfds docutils libxml2 rdkafka zlib lz4 nemea-framework protobuf ];
  cmakeFlags = [
    "-DCMAKE_C_FLAGS=-Wno-error=implicit-function-declaration"
  ]; 
 
  postInstall = ''
    srcRoot=$(cd .. && pwd)
    for plugin in unirec clickhouse; do
      echo "Building $plugin plugin..."
      echo srcRoot is $srcRoot $(ls)
      echo $(ls $srcRoot/extra_plugins/output)
      cd "$srcRoot/extra_plugins/output/$plugin"
      mkdir -p build && cd build
      cmake .. \
        -DCMAKE_INSTALL_PREFIX=$out \
        -DCMAKE_C_FLAGS="$CFLAGS -Wno-error=implicit-function-declaration" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
      make && make install
    done
  '';



  meta = {
    description = "Flexible, high-performance NetFlow v5/v9 and IPFIX flow data collector designed to be extensible by plugins";
    homepage = "https://github.com/CESNET/ipfixcol2";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
