let
	rust-overlay = (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"));
in
{ pkgs ? import <nixpkgs> { overlays = [ rust-overlay ]; } }:
let
  rust-toolchain = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
		  extensions = [ "rust-src" "rust-analyzer" ];
		};
in
pkgs.mkShellNoCC {
	# Kanidm dependencies
	buildInputs = with pkgs; [
		pkg-config

		rust-toolchain

		clang
		llvmPackages.bintools

		openssl

		mdbook
		mdbook-mermaid
	] ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) [
		systemd
		linux-pam
	];

	# https://github.com/rust-lang/rust-bindgen#environment-variables
	LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
	RUST_SRC_PATH = "${rust-toolchain}/lib/rustlib/src/rust/library";
}
