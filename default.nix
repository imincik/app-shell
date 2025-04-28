# Add specified programs (apps) on PATH.

# USAGE:
# nix-build --argstr apps "APP,APP,..." && ./result
# or
# $(nix build --print-out-paths --file ./default.nix --argstr apps "APP,APP,...")
# or
# nix build --file ./default.nix --argstr apps "APP,APP,..." && ./result

{ nixpkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") { }
, apps
, command ? null
}:

let
  inherit (nixpkgs)
    writeShellScript
    ;

  inherit (nixpkgs.lib)
    makeBinPath
    splitString
    ;

  # Doesn't work with package sets
  appsList = map (x: nixpkgs.${x}) (splitString "," apps);
  runCommand = if command != null then "-c ${command}" else ""; 

  activate = writeShellScript "activate-apps" ''
    export PS1="\[\033[1m\][app-shell]\[\033[m\]\040\w >\040"
    export PATH=$PATH:${makeBinPath appsList}

    ${nixpkgs.lib.getExe nixpkgs.bash} --norc ${runCommand}
  '';

in
activate
