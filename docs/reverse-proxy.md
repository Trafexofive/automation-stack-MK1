# Reverse Proxy Setup

This document explains how to configure your existing Nginx Proxy Manager (NPM) to work with the internal path-based routing proxy included in this stack.

## Configuration

1.  **Internal Proxy:** This stack includes an `internal-proxy` service that listens on port `81`. This service is responsible for routing requests to the correct service based on the URL path (e.g., `/n8n`, `/miniflux`).

2.  **Nginx Proxy Manager (NPM):** In your NPM, you need to create a new proxy host with the following settings:

    *   **Domain Name:** `automation.assisteo.ooguy.com` (or your desired domain)
    *   **Scheme:** `http`
    *   **Forward Hostname / IP:** The IP address of your Docker host (e.g., `192.168.1.100`) or `localhost` if NPM is running on the same machine.
    *   **Forward Port:** `5678`

Once this is configured, you will be able to access the services at the following URLs:

*   **n8n:** `https://automation.assisteo.ooguy.com/n8n/`
*   **Miniflux:** `https://automation.assisteo.ooguy.com/miniflux/`
*   **Crawl4AI API:** `https://automation.assisteo.ooguy.com/crawl4ai/`
*   **Scraperr:** `https://automation.assisteo.ooguy.com/scraperr/`
*   **Scrapper API:** `https://automation.assisteo.ooguy.com/scrapper/`
