# App shell

Create simple shell environment containing specified applications.

## Quick start

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
app-shell --apps qgis,gdal --python-packages numpy,pyproj
```

* Finally, launch QGIS on start

```bash
app-shell --apps qgis,gdal --python-packages numpy,pyproj -- qgis
```
