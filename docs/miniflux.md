# Miniflux

Miniflux is a minimalist and opinionated feed reader.

## Access

You can access the Miniflux web interface at [http://localhost:8080](http://localhost:8080).

The default administrator credentials are:

*   **Username:** `admin`
*   **Password:** `admin123`

## Configuration

The Miniflux service is configured in the `docker-compose.yml` file. Key configuration options include:

*   `DATABASE_URL`: The connection string for the Postgres database.
*   `RUN_MIGRATIONS`: Whether to run database migrations on startup.
*   `CREATE_ADMIN`: Whether to create an administrator account on startup.
*   `ADMIN_USERNAME`: The username for the administrator account.
*   `ADMIN_PASSWORD`: The password for the administrator account.
