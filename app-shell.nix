# USAGE:
# nix-build --argstr apps "APP,APP,..." && ./result
# or
# $(nix build --print-out-paths --file ./app-shell.nix --argstr apps "APP,APP,...")
# or
# nix build --file ./app-shell.nix --argstr apps "APP,APP,..." && ./result

{ nixpkgs ? "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
, apps ? null
, pythonPackages ? null
, libs ? null
, includeLibs ? null
, command ? null
}:

let
  nixpkgsFetched = if (builtins.substring 0 1 nixpkgs) == "/" then nixpkgs else (fetchTarball nixpkgs);
  pkgs = import nixpkgsFetched { };

  inherit (pkgs)
    writeShellScript
    ;

  inherit (pkgs.lib)
    getAttrFromPath
    makeBinPath
    makeIncludePath
    makeLibraryPath
    makeSearchPathOutput
    splitString
    ;

  inherit (pkgs.python3Packages)
    makePythonPath  # FIXME: doesn't work for other Python versions
    ;

  stringToPackage = str:
    getAttrFromPath (splitString "." str) pkgs;

  makePkgConfigPath = packages:
    makeSearchPathOutput "dev" "lib/pkgconfig" packages;

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
  libraryPath =
    if libs != null then ''
      export LIBRARY_PATH=${makeLibraryPath libsList}:$LIBRARY_PATH
      export LD_LIBRARY_PATH=${makeLibraryPath libsList}:$LD_LIBRARY_PATH
      export CMAKE_LIBRARY_PATH=${makeLibraryPath libsList}:$CMAKE_LIBRARY_PATH
      export PKG_CONFIG_PATH=${makePkgConfigPath libsList}:$PKG_CONFIG_PATH
    ''
    else
      "";

  includeLibsList =
    if includeLibs != null then
      map (x: stringToPackage x) (splitString "," includeLibs)
    else [ ];
  includePath =
    if includeLibs != null then ''
      export C_INCLUDE_PATH=${makeIncludePath includeLibsList}:$C_INCLUDE_PATH
      export CMAKE_INCLUDE_PATH=${makeIncludePath includeLibsList}:$CMAKE_INCLUDE_PATH
    ''
    else
      "";

  runCommand = if command != null then "-c '${command}'" else "";

  activate = writeShellScript "app-shell-run" ''
    export PS1="\[\033[1m\][app-shell]\[\033[m\]\040\w >\040"
    ${appsPath}
    ${pythonPath}
    ${libraryPath}
    ${includePath}

    ''${SHELL:-${pkgs.lib.getExe pkgs.bash} --norc} ${runCommand}
  '';

in
activate
