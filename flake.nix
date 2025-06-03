{
  description = "app-shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs }:

    let
      # Flake system
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
      });

    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

        in
        rec {
          app-shell = pkgs.callPackage ./package.nix { };
          default = app-shell;
        });
    };
}
