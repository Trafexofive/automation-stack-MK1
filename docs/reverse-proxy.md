# Reverse Proxy

This stack includes a built-in Nginx reverse proxy to provide easy access to all services from a single domain.

## Accessing Services

The reverse proxy is configured to listen on port 80 and route requests based on the URL path. You can access the services at these URLs:

*   **n8n:** [http://yourdomain.com/n8n/](http://yourdomain.com/n8n/)
*   **Miniflux:** [http://yourdomain.com/miniflux/](http://yourdomain.com/miniflux/)
*   **Crawl4AI API:** [http://yourdomain.com/crawl4ai/](http://yourdomain.com/crawl4ai/)
*   **Scraperr:** [http://yourdomain.com/scraperr/](http://yourdomain.com/scraperr/)
*   **Scrapper API:** [http://yourdomain.com/scrapper/](http://yourdomain.com/scrapper/)
*   **Portainer:** [http://yourdomain.com/portainer/](http://yourdomain.com/portainer/)

Replace `yourdomain.com` with your actual domain name.

## Configuration

The Nginx configuration is located in the `proxy.conf` file in the root of the project. The reverse proxy service itself is defined in the `docker-compose.yml` file.