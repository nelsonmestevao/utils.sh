with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "utils.sh";
  buildInputs = [
        bats
        gnumake
        shfmt
        shellcheck
    ];
}
