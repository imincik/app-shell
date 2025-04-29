# App shell

Create simple shell environment containing specified applications.

## Quick start

* Create shell containing QGIS and GDAL apps

```bash
./app-shell.bash --apps qgis,gdal
```

* Add Python with some modules as well

```bash
./app-shell.bash --apps qgis,gdal --python-packages numpy,pyproj
```

* Finally, launch QGIS on start

```bash
./app-shell.bash --apps qgis,gdal --python-packages numpy,pyproj -- qgis
```
