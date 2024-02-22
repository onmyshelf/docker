# OnMyShelf Collection Manager - Docker server

OnMyShelf docker server is the easy way to run OnMyShelf.

You can also install it manually (read [documentation here](https://docs.onmyshelf.app/admin-guide/)).

# Install on Linux (the easiest way)
Go into the current directory and run the install script:
```bash
./install.sh
```
If docker or docker compose install fails, please install it manually (see [official documentation here](https://docs.docker.com/get-docker/)).

# Install on MacOS
Be sure that you have [Docker Desktop](https://docs.docker.com/get-docker/) installed.

Go into the current directory and run the install script:
```bash
./install.sh
```

# Install on Windows
Be sure that you have [Docker Desktop](https://docs.docker.com/get-docker/) installed.

1. Copy `env.example` to `.env` and edit it
2. Go to the current directory and run the following command:
```bash
docker compose up -d
```

# Install manually
You can run OnMyShelf containers manually like this:

1. Create a network for OnMyShelf containers:
```bash
docker network create onmyshelf
```
2. Run database server:
```bash
docker run -d \
  --network onmyshelf --network-alias=db \
  -e MARIADB_RANDOM_ROOT_PASSWORD=yes \
  -e MARIADB_USER=onmyshelf -e MARIADB_PASSWORD=onmyshelf \
  -e MARIADB_DATABASE=onmyshelf \
  -v "$(pwd)/volumes/db/mysql:/var/lib/mysql" \
  mariadb:10.8
```
3. Run OnMyShelf server:
```bash
docker run -d \
  --network onmyshelf \
  -p 8035:80 \
  -v "$(pwd)/volumes/backups:/var/backups/onmyshelf" \
  -v "$(pwd)/volumes/logs:/var/log/onmyshelf" \
  -v "$(pwd)/volumes/media:/var/www/html/media" \
  -v "$(pwd)/volumes/api/modules:/var/www/html/api/v1/inc/modules" \
  onmyshelf/server:<VERSION>
```
**Note**: The first start may take a long time, because of the database initialization.

**Note**: Of course, you can add some environment variables as described in `env.exemple` file, or change the external port.

# After install
1. Login to your account. The default user is `onmyshelf` with password `onmyshelf`
2. Change your password in `My profile`

# Upgrade with script (Linux and MacOS only)
To upgrade OnMyShelf, run the following command (specify a version number if you want):
```bash
./upgrade.sh [-v VERSION]
```

**Note**: You can check all [available versions here](https://hub.docker.com/r/onmyshelf/server/tags).

# Upgrade with docker-compose
1. Change version number in `.env` file
2. Run the following commands:
```bash
docker compose pull
docker compose up -d
```

## The nightly version (unstable)
If you want to test OnMyShelf latest features, you can use the nightly version.

Be careful that this version can be highly unstable, as it is build every night with the latest commits of
the API and web interface projects.

If you want to use it, set version to `nightly` and do not forget to run `docker compose pull && docker compose up -d` periodically.

# Upgrade manually
1. Destroy old server container:
```bash
docker rm -fv <CONTAINER_NAME>
```
2. Pull the new version:
```bash
docker pull onmyshelf/server:<VERSION>
```
3. Run the server container as describe above.

# Start/stop/restart server
Run: 
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
