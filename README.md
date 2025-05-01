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

* Or maybe, compile some software

```c
// test.c

#include <stdio.h>
#include <curl/curl.h>

int main() {
    CURL *curl;

    curl = curl_easy_init();
    if (curl) {
        printf("It works !\n");
    } else {
        printf("libcurl failed to initialize.\n");
    }
    return 0;
}
```
```bash
  app-shell --apps gcc --libs curl --include-libs curl -- gcc test.c -lcurl -o test && ./test

  It works !
```


## Documentation

* Run `app-shell --help` to learn more.


## app-shell vs. nix-shell

[nix-shell](https://nix.dev/manual/nix/2.28/command-ref/nix-shell)
was originally designed to provide a debugging environment for Nix
derivations. It does a lot of magic and populates the environment with a lot
of unnecessary content (packages, shell environment variables and functions).

`app-shell` is much more simple, cleaner and lighter. It only fetches required
packages to the `/nix/store` and propagates them to the environment via relevant
environment variables.
