{ stdenv, cmake, qt6, pkg-config }:

stdenv.mkDerivation {
  pname = "quickshell-metrics";
  version = "0.0.1";
  
  src = ./.;
  
  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ qt6.qtbase qt6.qtdeclarative ];
  
  buildPhase = ''
    cmake .
    make -j $NIX_BUILD_CORES
  '';
  
  installPhase = ''
    mkdir -p $out/lib
    cp *.so $out/lib/ || cp *.a $out/lib/
    mkdir -p $out/include
    cp *.h $out/include/ || echo "No headers to copy"
  '';
}
