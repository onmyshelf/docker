# OnMyShelf Collection Manager - Docker server

# Requirements
- docker
- docker-compose

# Install
1. Copy `env.example` to `.env` and edit it
2. Run `./install.sh`
3. Login to your account. The default user is `onmyshelf` with password `onmyshelf`
4. Change your password in `My profile`

**Note**: The first start may take a long time, because of the database initialization.

# Upgrade
To upgrade OnMyShelf, run the following command (specify a version number if you want):
```bash
./upgrade.sh [VERSION]
```

# Start/stop/restart server
Run `docker-compose start|stop|restart`

# Reinstall / Uninstall
- Run `docker-compose down` to shutdown OnMyShelf server
- Delete the `volumes` directory to delete all data if your want to reinstall a fresh server
- Delete this current directory to completely uninstall OnMyShelf and remove all files

# Behind a reverse proxy
If you want to put OnMyShelf behind a reverse proxy, don't forget to increase the max body size.

e.g. on nginx: `client_max_body_size 128M;`

# Backups
If you want to backup OnMyShelf database, run the following command:
```bash
docker-compose exec api /backup.sh
```
The database dump file is in the `volumes/api/backups` folder.

If you want to backup all files including logs, you can backup the whole `volumes/api` folder.

# Official docker images
Official docker images are stored on Docker Hub: https://hub.docker.com/u/onmyshelf

Put stars on them to support us!

# License
This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for the full license text.

# Credits
Website: https://onmyshelf.cm

Source code: https://github.com/onmyshelf/docker
