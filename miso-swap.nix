{ mkDerivation, base, miso, stdenv }:
mkDerivation {
  pname = "miso-swap";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base miso ];
  description = "Swappable Model component";
  license = stdenv.lib.licenses.unfree;
}
