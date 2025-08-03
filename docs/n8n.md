# n8n

n8n is a workflow automation tool that allows you to connect different services and automate tasks.

## Access

You can access the n8n web interface at [http://localhost:5678](http://localhost:5678).

## Configuration

The n8n service is configured in the `docker-compose.yml` file. Key configuration options include:

*   `N8N_PORT`: The port on which the n8n web interface is exposed.
*   `DB_TYPE`: The type of database to use (in this case, `postgresdb`).
*   `DB_POSTGRESDB_HOST`: The hostname of the Postgres database.
*   `DB_POSTGRESDB_DATABASE`: The name of the database to use.
*   `DB_POSTGRESDB_USER`: The username for the database.
*   `DB_POSTGRESDB_PASSWORD`: The password for the database.
