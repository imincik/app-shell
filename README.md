# App shell

Create a temporary shell environment containing specified applications.


## Quick start

* Install Nix
  [(learn more about this installer)](https://zero-to-nix.com/start/install)
```bash
curl --proto '=https' --tlsv1.2 -sSf \
    -L https://install.determinate.systems/nix \
    | sh -s -- install
  ```

* Install app-shell

```bash
  nix profile install github:imincik/app-shell#app-shell
```

* Create shell containing QGIS and GDAL apps

```bash
app-shell --apps qgis,gdal
```

* Add Python with some modules as well

```bash
app-shell --apps qgis,gdal,python3 --python-packages python3Packages.numpy,python3Packages.pyproj
```

* Finally, launch QGIS on start

```bash
app-shell --apps qgis,gdal,python3 --python-packages python3Packages.numpy,python3Packages.pyproj -- qgis
```


## Documentation

* Run `app-shell --help` to learn more.
