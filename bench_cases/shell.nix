{ pkgs ? import <nixpkgs> {} }:

with pkgs; stdenv.mkDerivation {
  name = "rust-env";
  nativeBuildInputs = [
    rustup cargo

    # Example Build-time Additional Dependencies
    pkgconfig
  ];
  buildInputs = [
    # Example Run-time Additional Dependencies
    openssl
  ];

  # Set Environment Variables
  RUST_BACKTRACE = 1;
}
