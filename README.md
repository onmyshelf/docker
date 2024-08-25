# OnMyShelf Collection Manager - Docker server

OnMyShelf docker server is the easy way to run OnMyShelf.

You can also install it manually (read [documentation here](https://docs.onmyshelf.app/admin-guide/)).

# Install procedure
## Install on Linux (the easiest way)
Go into the current directory and run the install script:
```bash
./install.sh
```
If docker or docker compose install fails, please install it manually (see [official documentation here](https://www.docker.com)).

## Install on MacOS
Be sure that you have [Docker](https://www.docker.com) installed.

Go into the current directory and run the install script:
```bash
./install.sh
```

## Install using docker compose
If you're using Windows, you can use this technique.
Be sure that you have [Docker](https://www.docker.com) installed.

1. Copy `env.example` to `.env` and edit it
2. Go to the current directory and run the following command:
```bash
docker compose up -d
```

# After install
1. Login with user `onmyshelf` and password `onmyshelf`
2. Change your password in `My profile`

# Upgrade procedure
## Upgrade on Linux or MacOS (the easiest way)
To upgrade OnMyShelf, run the following command (specify a version number if you want):
```bash
./upgrade.sh
```

## Upgrade using git
If you're using Windows, you can use this technique.
Run these commands:
```bash
git pull
docker compose up -d
```

## Upgrade without using git
1. Change version number in `.env` file
2. Run the following commands:
```bash
docker compose pull
docker compose up -d
```

**Note**: You can check all [available versions here](https://hub.docker.com/r/onmyshelf/server/tags).

# The nightly version (unstable)
If you want to test OnMyShelf latest features, you can use the nightly version.

Be careful that this version can be highly unstable, as it is build every night with the latest commits of
the API and web interface projects.
**You should not use nightly version in production.**

If you want to use it, set `VERSION=nightly` in `.env` file and do not forget to run `docker compose pull && docker compose up -d` periodically.

# Start/stop/restart server
Run these commands:
```bash
docker compose start|stop|restart
```

# Reinstall / Uninstall
- Run `docker compose down` to shutdown OnMyShelf server
- Delete the `volumes` directory to delete all data if your want to reinstall a fresh server
- Delete this current directory to completely uninstall OnMyShelf and remove all files

# Official docker image
The official docker image used in this project is stored on Docker Hub: https://hub.docker.com/r/onmyshelf/server/

Please put a star on it to show your support!

# Build your own image
You can build your own OnMyShelf image by following [these instructions](build/README.md).

# License
This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for the full license text.

# Credits
Website: https://onmyshelf.app

Source code: https://github.com/onmyshelf/docker
