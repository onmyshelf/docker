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

# License
OnMyShelf is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for the full license text.

# Credits
Website: https://onmyshelf.cm

Source code: https://github.com/onmyshelf/docker

Author: Jean Prunneaux https://jean.prunneaux.com
