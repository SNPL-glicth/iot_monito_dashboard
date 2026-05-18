{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.flutter
    pkgs.cmake
    pkgs.pkg-config
    pkgs.libsecret
    pkgs.gtk3
    pkgs.glib
  ];

  # Flutter necesita esto para Linux
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.libsecret
    pkgs.gtk3
    pkgs.glib
  ];
}
