# Deploy and Host Frappe on Railway

Frappe is an open-source, low-code framework for building full-stack web applications with a built-in admin, REST API, and website layer.

## About Hosting Frappe

This template pins the Frappe `v16` line through the `frappe/erpnext:v16.34.1` base image. It deploys one Frappe application service plus private MariaDB and Redis services. On first boot it creates the site as vanilla Frappe and initializes the Administrator account. Subsequent boots run `bench migrate` before starting application processes.

Frappe's standard production topology shares the `sites` directory across nginx, Gunicorn, Socket.IO, workers, and scheduler. Railway does not share volumes across services, so this template supervises those processes in one application container where they safely share one persistent volume.

## Common Use Cases

- Custom internal tools and business apps on the Frappe framework
- REST APIs backed by a Document model and role-based permissions
- Websites and portals built on Frappe's web layer
- A base for installing apps such as ERPNext, HRMS, or your own

## Dependencies for Frappe Hosting

- MariaDB 11.8.8 with durable storage
- Redis queue/cache with durable storage
- A comparatively high memory allocation; Frappe v16 is a substantial multi-process stack

### Deployment Dependencies

- [Frappe Framework](https://github.com/frappe/frappe)
- [Frappe Docker](https://github.com/frappe/frappe_docker)
- [Frappe documentation](https://docs.frappe.io/framework/user/en/introduction)

### Implementation Details

Open the `frappe` domain and sign in as `Administrator` using the generated `ADMIN_PASSWORD` variable. The public service listens through nginx on port `8080`; `/api/method/ping` is used for health checks. MariaDB and Redis remain private. The Frappe `sites` volume and MariaDB volume receive scheduled backups.

### Why Deploy Frappe on Railway?

Railway provides private networking, persistent volumes, generated secrets, HTTPS, health checks, logs, and restart management while the template preserves the process relationships expected by Frappe.
