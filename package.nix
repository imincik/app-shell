{ stdenv, bash, shellcheck, makeWrapper}:
stdenv.mkDerivation {
  pname = "app-shell";
  version = "0.1.0";

  src = builtins.path { path = ./.; name = "app-shell"; };

  unpackPhase = "true";
  buildPhase = "true";

  buildInputs = [ bash ];
  checkInputs = [ shellcheck ];
  nativeBuildInputs = [ makeWrapper ];

  doCheck = true;
  checkPhase = ''shellcheck $src/app-shell.bash'';

  installPhase = ''
    mkdir -p $out/bin $out/share/nix

    cp -a $src/app-shell.nix $out/share/nix

    cp $src/app-shell.bash $out/bin/app-shell
    chmod +x $out/bin/app-shell

    wrapProgram $out/bin/app-shell \
      --set APP_SHELL_NIX_DIR $out/share/nix
  '';
}
