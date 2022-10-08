# OnMyShelf Collection Manager - Docker server

# Requirements
- docker
- docker-compose

# Install (the easiest way)
1. Copy `env.example` to `.env` and edit it
2. Run `./install.sh`
3. Login to your account. The default user is `onmyshelf` with password `onmyshelf`
4. Change your password in `My profile`

**Note**: The first start may take a long time, because of the database initialization.

# Install manually
You can run OnMyShelf containers manually like this:

1. Create a network for OnMyShelf containers:
```bash
docker network create onmyshelf
```
2. Run database server:
```bash
docker run -d --network onmyshelf --network-alias=db \
  -e MARIADB_RANDOM_ROOT_PASSWORD=yes \
  -e MARIADB_USER=onmyshelf -e MARIADB_PASSWORD=onmyshelf \
  -e MARIADB_DATABASE=onmyshelf \
  -v "$(pwd)/volumes/db/mysql:/var/lib/mysql" \
  mariadb:10.8
```
3. Run OnMyShelf server:
```bash
docker run -d --network onmyshelf \
  -p 8080:80 \
  -v "$(pwd)/volumes/backups:/var/backups/onmyshelf" \
  -v "$(pwd)/volumes/logs:/var/log/onmyshelf" \
  -v "$(pwd)/volumes/media:/var/www/html/media" \
  -v "$(pwd)/volumes/api/modules:/var/www/html/api/v1/inc/modules" \
  onmyshelf/server:1.0.0-rc.3
```
**Note**: Of course, you can add some environment variables as described in `env.exemple` file, or change the external port.

# Upgrade
To upgrade OnMyShelf, run the following command (specify a version number if you want):
```bash
./upgrade.sh [VERSION]
```

# Upgrade manually
Pull the new image and recreate the server container.

# Start/stop/restart server
Run `docker-compose start|stop|restart`

# Reinstall / Uninstall
- Run `docker-compose down` to shutdown OnMyShelf server
- Delete the `volumes` directory to delete all data if your want to reinstall a fresh server
- Delete this current directory to completely uninstall OnMyShelf and remove all files

# Behind a reverse proxy
It is recommanded for security concerns to put OnMyShelf behind a reverse proxy.

Don't forget to increase the max body size.

e.g. on nginx: `client_max_body_size 128M;`

# Backups
If you want to backup OnMyShelf database, run the following command:
```bash
docker-compose exec server /backup.sh
```
The database dump file is in the `volumes/backups` folder.
It's also recommended to backup your `volumes/media` folder.

# Official docker images
Official docker images are stored on Docker Hub: https://hub.docker.com/u/onmyshelf

Put some stars on them to support us!

# License
This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for the full license text.

# Credits
Website: https://onmyshelf.cm

Source code: https://github.com/onmyshelf/docker
