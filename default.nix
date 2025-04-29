# Create simple shell environment containing specified applications.

# USAGE:
# nix-build --argstr apps "APP,APP,..." && ./result
# or
# $(nix build --print-out-paths --file ./default.nix --argstr apps "APP,APP,...")
# or
# nix build --file ./default.nix --argstr apps "APP,APP,..." && ./result

{ nixpkgs ? "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
, apps ? null
, pythonPackages ? null
, command ? null
}:

let
  pkgs = import (fetchTarball nixpkgs) { };

  inherit (pkgs)
    writeShellScript
    ;

  inherit (pkgs.lib)
    makeBinPath
    splitString
    ;

  inherit (pkgs.python3Packages)
    makePythonPath
    ;

  appsList =
    if apps != null then
      map (x: pkgs.${x}) (splitString "," apps)
    else [ ];
  appsPath =
    if apps != null then
      "export PATH=${makeBinPath appsList}:$PATH"
    else
      "";

  pythonPackagesList =
    if pythonPackages != null then
      map (x: pkgs.python3Packages.${x}) (splitString "," pythonPackages)
    else [ ];
  pythonPath =
    if pythonPackages != null then
      "export PYTHONPATH=${makePythonPath pythonPackagesList}:$PYTHONPATH"
    else
      "";

  runCommand = if command != null then "-c '${command}'" else "";

  activate = writeShellScript "app-shell" ''
    export PS1="\[\033[1m\][app-shell]\[\033[m\]\040\w >\040"
    ${appsPath}
    ${pythonPath}

    ${pkgs.lib.getExe pkgs.bash} --norc ${runCommand}
  '';

in
activate
