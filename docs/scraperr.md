# Scraperr

Scraperr is a self-hosted web scraper with a web UI.

## Access

You can access the Scraperr web interface at [http://localhost:8001](http://localhost:8001).

## Configuration

The Scraperr service is configured in the `docker-compose.yml` file. Key configuration options include:

*   `DATABASE_URL`: The connection string for the SQLite database.
*   `REDIS_URL`: The URL of the Redis instance to use for caching and queuing.
