# Frappe on Railway

A Railway-compatible deployment of [Frappe Framework](https://github.com/frappe/frappe), pinned to the Frappe `v16` line via the `frappe/erpnext:v16.34.1` base image.

Railway does not support sharing one volume across independent services. Frappe's production topology shares `sites` between backend, frontend, WebSocket, workers, and scheduler, so this template runs those application processes under Supervisor in one container while keeping MariaDB and Redis as separate private services.

## Services

- `frappe`: Frappe backend, nginx frontend, Socket.IO, short and long workers, scheduler
- `mariadb`: persistent MariaDB 11.8.8
- `redis`: persistent Redis queue/cache

The first deployment creates the `frontend` site as vanilla Frappe. Later deployments run `bench migrate` automatically.

## Installing apps

Sites are created with Frappe only. To add applications, set the `FRAPPE_APPS` environment variable at build time as a comma-separated list of `<git-url>@<branch>` entries, for example:

```
FRAPPE_APPS=https://github.com/frappe/erpnext@version-16,https://github.com/frappe/hrms@version-16
```

On boot the template installs any app from that list that is not already installed on the site, and runs `bench migrate` on every subsequent boot. ERPNext ships in the base image, so listing it reuses the pinned `v16.34.1` copy instead of cloning the branch. Use public HTTPS URLs; the build has no Git credentials.

> Railway config-as-code reads `FRAPPE_APPS` from the service's build variables. Changing it requires a rebuild, because application assets are compiled into the image.

## Updating

Update and test the base image and the apps in `FRAPPE_APPS` together. Frappe application versions must remain compatible.
