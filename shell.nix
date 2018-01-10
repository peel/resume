{pkgs ? import <nixpkgs> {} }:
let
  org-export = pkgs.stdenv.mkDerivation {
    name = "org-export";
    src = pkgs.fetchFromGitHub {
      owner = "nhoffman";
      repo = "org-export";
      rev = "997ac72";
      sha256 = "0wwraf0b8q5j24baji1f36zkf5bd7zcb2qms8m2fkwqhkd9a6c7l";
    };
    buildInputs = with pkgs; [ bash ];
    phases = [ "buildPhase" ];
    buildCommand = ''
      mkdir -p $out/bin
      cp -r $src/* $out/bin/
      substituteInPlace $out/bin/org-export \
        --replace "/bin/bash" ${pkgs.bash}/bin/bash
      '';
  };
in pkgs.stdenv.mkDerivation {
  name = "deals-entrypoint";
  buildInputs = with pkgs; [ org-export emacs bash wkhtmltopdf ];
  shellHook = ''
    alias org-export="${org-export}/bin/org-export"
    mv resume.pdf resume.pdf.bak
    org-export html --infile index.org
    wkhtmltopdf index.html
  '';
}
