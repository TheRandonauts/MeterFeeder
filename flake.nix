{
  description = "MeterFeeder: C++ driver for Core Invention MED quantum random number generator USB devices";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # libmeterfeeder.so statically links FTDI's proprietary D2XX driver
        # (ftd2xx/linux/libftd2xx.a, vendored upstream with no source).
        config.allowUnfreePredicate = pkg: (pkg.pname or "") == "libmeterfeeder";
      };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "libmeterfeeder";
        version = "0-unstable-${self.shortRev or self.dirtyShortRev or "dev"}";
        src = ./.;

        buildInputs = [ pkgs.libusb1 ];

        # Mirrors linux-build-lib.sh. ftd2xx/linux/libftd2xx.a is FTDI's
        # proprietary D2XX driver, vendored upstream with no source; it has
        # no unversioned .so symlink in ftd2xx/linux, so -lftd2xx resolves to
        # the .a and gets folded statically into libmeterfeeder.so (verified:
        # the resulting .so has no NEEDED entry for it, only libusb-1.0,
        # libpthread, libstdc++, libm, libgcc_s, libc).
        buildPhase = ''
          runHook preBuild
          g++ -std=c++11 -O2 -fPIC -shared \
            ./src/*.cpp \
            -o libmeterfeeder.so \
            -lusb-1.0 -L./ftd2xx/linux -lftd2xx -lpthread
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib $out/include $out/share/meterfeeder/udev
          cp libmeterfeeder.so $out/lib/
          cp src/*.h $out/include/
          cp udev/99-meterfeeder.rules udev/ftdi_unbind.sh $out/share/meterfeeder/udev/
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "C++ driver for Core Invention MED QRNG USB devices, exposing the MF_* C API";
          homepage = "https://github.com/TheRandonauts/MeterFeeder";
          # No LICENSE file upstream, and libftd2xx.a (FTDI's proprietary D2XX
          # driver) is statically linked in. Confirm redistribution terms
          # against FTDI's D2XX EULA before distributing this build outside
          # Randonautica's own infrastructure.
          license = licenses.unfree;
          platforms = [ "x86_64-linux" ];
        };
      };
    };
}
