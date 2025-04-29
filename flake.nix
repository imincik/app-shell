{
  description = "app-shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:

    let
      # Flake system
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

        in
        rec {
          app-shell = pkgs.callPackage (
            { stdenv, lib, bash, shellcheck, makeWrapper}:
            stdenv.mkDerivation {
              pname = "app-shell";
              version = "0.1.0";

              src = ./.;

              unpackPhase = "true";
              buildPhase = "true";

              buildInputs = [ bash ];
              checkInputs = [ shellcheck ];
              nativeBuildInputs = [ makeWrapper ];

              doCheck = true;
              checkPhase = ''shellcheck $src/app-shell.bash'';

              installPhase = ''
                mkdir -p $out/bin $out/share/nix

                cp -a $src/default.nix $out/share/nix

                cp $src/app-shell.bash $out/bin/app-shell
                chmod +x $out/bin/app-shell

                wrapProgram $out/bin/app-shell \
                  --set APP_SHELL_NIX_DIR $out/share/nix
              '';
            }
          ) { };
          default = app-shell;
        });
    };
}
