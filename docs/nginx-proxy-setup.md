# Nginx Proxy Manager Setup

This document explains how to configure Nginx Proxy Manager to expose the services in this stack on your local network.

## Connecting to the Network

For Nginx Proxy Manager to see the services in this stack, you need to connect it to the `automation_network`. You can do this from the command line:

```bash
docker network connect automation-stack-mk1_automation_network nginx-proxy-manager
```

Replace `nginx-proxy-manager` with the actual name of your Nginx Proxy Manager container if it's different.

## Adding Proxy Hosts

In the Nginx Proxy Manager web UI, you'll need to add a new proxy host for each service you want to expose. Here's a template for the configuration:

*   **Domain Name:** `n8n.yourdomain.com` (or any other domain you want to use)
*   **Scheme:** `http`
*   **Forward Hostname / IP:** The name of the service container (e.g., `n8n`, `miniflux`)
*   **Forward Port:** The internal port of the service (e.g., `5678` for n8n)

Here are the specific details for each service:

### n8n

*   **Domain Name:** `n8n.yourdomain.com`
*   **Forward Hostname / IP:** `n8n`
*   **Forward Port:** `5678`

### Miniflux

*   **Domain Name:** `miniflux.yourdomain.com`
*   **Forward Hostname / IP:** `miniflux`
*   **Forward Port:** `8080`

### Crawl4AI

*   **Domain Name:** `crawl4ai.yourdomain.com`
*   **Forward Hostname / IP:** `crawl4ai`
*   **Forward Port:** `11235`

### Scraperr

*   **Domain Name:** `scraperr.yourdomain.com`
*   **Forward Hostname / IP:** `scraperr`
*   **Forward Port:** `8000`

### Scrapper

*   **Domain Name:** `scrapper.yourdomain.com`
*   **Forward Hostname / IP:** `scrapper`
*   **Forward Port:** `3000`
