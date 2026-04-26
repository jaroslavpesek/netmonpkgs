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
    rev = "a014dac5e422bd323aa131aa7680c6d7809d5733";
    hash = "sha256-tK/5WgGz5f8OLOtL7JkiK/nLM4jLW0JJ8UhDgt9GxVc=";
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
