# USAGE:
# nix-build --argstr apps "APP,APP,..." && ./result
# or
# $(nix build --print-out-paths --file ./default.nix --argstr apps "APP,APP,...")
# or
# nix build --file ./default.nix --argstr apps "APP,APP,..." && ./result

{ nixpkgs ? "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
, apps ? null
, pythonPackages ? null
, libs ? null
, command ? null
}:

let
  pkgs = import (fetchTarball nixpkgs) { };

  inherit (pkgs)
    writeShellScript
    ;

  inherit (pkgs.lib)
    makeBinPath
    makeLibraryPath
    splitString
    getAttrFromPath
    ;

  inherit (pkgs.python3Packages)
    makePythonPath  # FIXME: doesn't work for other Python versions
    ;

  stringToPackage = str:
    getAttrFromPath (splitString "." str) pkgs;

  appsList =
    if apps != null then
      map (x: stringToPackage x) (splitString "," apps)
    else [ ];
  appsPath =
    if apps != null then
      "export PATH=${makeBinPath appsList}:$PATH"
    else
      "";

  pythonPackagesList =
    if pythonPackages != null then
      map (x: stringToPackage x ) (splitString "," pythonPackages)
    else [ ];
  pythonPath =
    if pythonPackages != null then
      "export PYTHONPATH=${makePythonPath pythonPackagesList}:$PYTHONPATH"
    else
      "";

  libsList =
    if libs != null then
      map (x: stringToPackage x) (splitString "," libs)
    else [ ];
  ldLibraryPath =
    if libs != null then
      "export LD_LIBRARY_PATH=${makeLibraryPath libsList}:$LD_LIBRARY_PATH"
    else
      "";

  runCommand = if command != null then "-c '${command}'" else "";

  activate = writeShellScript "app-shell-run" ''
    export PS1="\[\033[1m\][app-shell]\[\033[m\]\040\w >\040"
    ${appsPath}
    ${pythonPath}
    ${ldLibraryPath}

    ${pkgs.lib.getExe pkgs.bash} --norc ${runCommand}
  '';

in
activate
