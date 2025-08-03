# N8N Automation Stack - Complete Integration Reference

## STACK ARCHITECTURE OVERVIEW

### Service Endpoints & Internal Communication
```
Internal Docker Network: automation_network
External Network: npm_network (NPM SSL termination)

SERVICE MAPPING:
├── n8n (Workflow Engine)
│   ├── Internal: http://n8n:5678
│   ├── External: https://n8n.yourdomain.com
│   └── Database: postgres://n8n:${N8N_DB_PASS:-pass}@postgres:5432/n8n
│
├── postgres (Database)
│   ├── Internal: postgres:5432
│   ├── Databases: n8n, miniflux
│   └── No external access (security)
│
├── redis (Cache/Queue)
│   ├── Internal: redis://redis:6379
│   └── No external access (security)
│
├── miniflux (RSS Aggregator)
│   ├── Internal: http://miniflux:8080
│   ├── External: https://miniflux.yourdomain.com
│   ├── Database: postgres://miniflux:${MINIFLUX_PASS:-miniflux}@postgres/miniflux?sslmode=disable
│   └── Admin: admin/${MINIFLUX_ADMIN_PASS:-admin123}
│
├── crawl4ai (AI Web Scraper)
│   ├── Internal: http://crawl4ai:11235
│   ├── External: https://crawl4ai.yourdomain.com
│   ├── API Token: ${CRAWL4AI_TOKEN:-your-secret-token}
│   └── Cache: redis://redis:6379
│
├── scraperr (Scheduled Scraper)
│   ├── Internal: http://scraperr:8000
│   ├── External: https://scraperr.yourdomain.com
│   ├── Database: SQLite internal
│   └── Cache: redis://redis:6379
│
└── scrapper (Article Extractor)
    ├── Internal: http://scrapper:3000
    ├── External: https://scrapper.yourdomain.com
    └── Headless browser: Playwright
```

## N8N NODE CONFIGURATIONS

### HTTP Request Node Templates

#### 1. Crawl4AI - AI-Powered Web Scraping
```json
{
  "name": "Crawl4AI Scraper",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "http://crawl4ai:11235/crawl",
    "method": "POST",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "headers": {
      "Authorization": "Bearer {{ $env.CRAWL4AI_TOKEN || 'your-secret-token' }}",
      "Content-Type": "application/json"
    },
    "body": {
      "url": "{{ $json.target_url }}",
      "extraction_strategy": "llm",
      "word_count_threshold": 10,
      "extraction_strategy_args": {
        "provider": "ollama/llama3",
        "api_token": "optional",
        "instruction": "Extract all articles and news items with titles, summaries, and links"
      },
      "chunking_strategy": "RegexChunking",
      "css_selector": "",
      "screenshot": false,
      "user_agent": "Mozilla/5.0 (compatible; N8N-Bot/1.0)",
      "verbose": true
    }
  }
}
```

#### 2. Scraperr - Scheduled Web Scraping
```json
{
  "name": "Scraperr Job Creation",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "http://scraperr:8000/api/scrapers",
    "method": "POST",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": {
      "name": "{{ $json.scraper_name }}",
      "url": "{{ $json.target_url }}",
      "selector": "{{ $json.css_selector || 'body' }}",
      "schedule": "{{ $json.cron_schedule || '0 */6 * * *' }}",
      "enabled": true,
      "webhook_url": "https://n8n.yourdomain.com/webhook/scraperr-results"
    }
  }
}
```

#### 3. Scrapper - Article Content Extraction
```json
{
  "name": "Scrapper Article Extract",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "http://scrapper:3000/api/scrape",
    "method": "GET",
    "qs": {
      "url": "{{ $json.article_url }}",
      "mode": "article",
      "include_raw_html": false,
      "include_screenshot": false,
      "wait_for": 2000,
      "block_resources": true
    }
  }
}
```

#### 4. Miniflux - RSS Management
```json
{
  "name": "Miniflux Add Feed",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "http://miniflux:8080/v1/feeds",
    "method": "POST",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpBasicAuth",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": {
      "feed_url": "{{ $json.rss_url }}",
      "category_id": 1,
      "crawler": true,
      "user_agent": "Miniflux",
      "username": "admin",
      "password": "{{ $env.MINIFLUX_ADMIN_PASS || 'admin123' }}",
      "ignore_http_cache": false,
      "allow_self_signed_certificates": false,
      "fetch_via_proxy": false,
      "scraper_rules": "",
      "rewrite_rules": "",
      "blocklist_rules": "",
      "keeplist_rules": ""
    }
  }
}
```

### Redis Operations

#### Redis Cache Check
```json
{
  "name": "Redis Cache Check",
  "type": "n8n-nodes-base.redis",
  "parameters": {
    "operation": "get",
    "key": "cache:{{ $json.url | hash }}",
    "keyType": "string"
  },
  "credentials": {
    "host": "redis",
    "port": 6379,
    "database": 0
  }
}
```

#### Redis Cache Store
```json
{
  "name": "Redis Cache Store",
  "type": "n8n-nodes-base.redis",
  "parameters": {
    "operation": "set",
    "key": "cache:{{ $json.url | hash }}",
    "value": "{{ JSON.stringify($json) }}",
    "expire": true,
    "ttl": 3600,
    "keyType": "string"
  }
}
```

### PostgreSQL Database Operations

#### Store Scraped Data
```json
{
  "name": "Store Scraped Content",
  "type": "n8n-nodes-base.postgres",
  "parameters": {
    "operation": "insert",
    "schema": "public",
    "table": "scraped_content",
    "columns": "url, title, content, scraped_at, source_service",
    "additionalFields": {
      "mode": "independently"
    }
  },
  "credentials": {
    "host": "postgres",
    "database": "n8n",
    "user": "n8n",
    "password": "{{ $env.N8N_DB_PASS || 'pass' }}",
    "port": 5432
  }
}
```

## AUTOMATION WORKFLOW TEMPLATES

### 1. RSS-to-AI Content Analysis Pipeline
```
[Schedule Trigger: Every 15 minutes]
  ↓
[Miniflux: Get Unread Items] → http://miniflux:8080/v1/entries?status=unread
  ↓
[Filter: New Articles Only]
  ↓
[Crawl4AI: Extract Full Content] → http://crawl4ai:11235/crawl
  ↓
[OpenAI/Local LLM: Summarize & Categorize]
  ↓
[Redis: Cache Results] → redis:6379
  ↓
[PostgreSQL: Store Analysis] → postgres:5432
  ↓
[Webhook: Notify External Systems]
```

### 2. Competitive Intelligence Scraper
```
[Schedule Trigger: Daily at 6 AM]
  ↓
[PostgreSQL: Get Competitor URLs]
  ↓
[Loop Over URLs]
  ├─[Scraperr: Schedule Long-term Monitoring] → scraperr:8000/api/scrapers
  ├─[Scrapper: Extract Current Content] → scrapper:3000/api/scrape
  └─[Crawl4AI: Deep AI Analysis] → crawl4ai:11235/crawl
  ↓
[Data Merge & Comparison]
  ↓
[Redis: Store Trending Data] → redis:6379
  ↓
[Generate Intelligence Report]
  ↓
[Email/Slack Notification]
```

### 3. Multi-Source News Aggregator
```
[Webhook Trigger: /webhook/news-sources]
  ↓
[Switch Node: Route by Source Type]
  ├─RSS → [Miniflux API] → miniflux:8080/v1/entries
  ├─Website → [Scrapper Extract] → scrapper:3000/api/scrape  
  └─Complex Site → [Crawl4AI] → crawl4ai:11235/crawl
  ↓
[Content Deduplication] ← [Redis Cache Check] → redis:6379
  ↓
[AI Content Analysis & Scoring]
  ↓
[PostgreSQL: Store Unique Articles] → postgres:5432
  ↓
[Generate Daily Digest]
```

### 4. E-commerce Price Monitor
```
[Schedule Trigger: Every 2 hours]
  ↓
[PostgreSQL: Get Product URLs to Monitor]
  ↓
[HTTP Request: Check Rate Limits] → redis:6379
  ↓
[Crawl4AI: Extract Product Data] → crawl4ai:11235/crawl
  {
    "extraction_strategy": "css",
    "css_selector": ".price, .title, .availability"
  }
  ↓
[Data Validation & Price Comparison]
  ↓
[Redis: Store Price History] → redis:6379
  ↓
[Condition: Price Drop > 10%]
  ↓
[Email/Discord Alert]
```

## WEBHOOK CONFIGURATIONS

### Incoming Webhooks (for external systems to trigger n8n)
```
RSS Updates: https://n8n.yourdomain.com/webhook/rss-update
Scraperr Results: https://n8n.yourdomain.com/webhook/scraperr-results  
Manual Scrape: https://n8n.yourdomain.com/webhook/manual-scrape
Price Alerts: https://n8n.yourdomain.com/webhook/price-alert
Content Analysis: https://n8n.yourdomain.com/webhook/analyze-content
```

### Outgoing Webhooks (n8n calling external services)
```
Slack Notifications: YOUR_SLACK_WEBHOOK_URL
Discord Alerts: YOUR_DISCORD_WEBHOOK_URL
Custom API: https://your-external-api.com/webhook
Analytics: https://your-analytics-platform.com/events
```

## RATE LIMITING & CACHING STRATEGIES

### Redis-Based Rate Limiting
```javascript
// Function Node for Rate Limiting
const redisKey = `rate_limit:${$json.domain}`;
const currentCount = await $redis.get(redisKey) || 0;

if (currentCount >= 100) { // 100 requests per hour
  throw new Error('Rate limit exceeded');
}

await $redis.setex(redisKey, 3600, parseInt(currentCount) + 1);
return $json;
```

### Intelligent Caching
```javascript
// Function Node for Smart Caching
const cacheKey = `content:${$crypto.createHash('md5').update($json.url).digest('hex')}`;
const cached = await $redis.get(cacheKey);

if (cached && (Date.now() - JSON.parse(cached).timestamp) < 3600000) { // 1 hour
  return JSON.parse(cached).data;
}

// Proceed with scraping...
```

## DATABASE SCHEMAS

### Scraped Content Table
```sql
CREATE TABLE scraped_content (
  id SERIAL PRIMARY KEY,
  url TEXT NOT NULL,
  title TEXT,
  content TEXT,
  metadata JSONB,
  scraped_at TIMESTAMP DEFAULT NOW(),
  source_service VARCHAR(50),
  content_hash VARCHAR(64),
  is_processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_scraped_content_url ON scraped_content(url);
CREATE INDEX idx_scraped_content_scraped_at ON scraped_content(scraped_at);
CREATE INDEX idx_scraped_content_source ON scraped_content(source_service);
```

### RSS Feeds Tracking
```sql
CREATE TABLE rss_feeds (
  id SERIAL PRIMARY KEY,
  feed_url TEXT UNIQUE NOT NULL,
  title TEXT,
  last_fetched TIMESTAMP,
  items_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  miniflux_id INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Price Monitoring
```sql
CREATE TABLE price_history (
  id SERIAL PRIMARY KEY,
  product_url TEXT NOT NULL,
  product_name TEXT,
  price DECIMAL(10,2),
  currency VARCHAR(3) DEFAULT 'USD',
  availability TEXT,
  scraped_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB
);
```

## ERROR HANDLING & MONITORING

### Service Health Checks
```json
{
  "name": "Health Check All Services",
  "nodes": [
    {
      "name": "Check Crawl4AI",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://crawl4ai:11235/health",
        "method": "GET"
      }
    },
    {
      "name": "Check Scraperr", 
      "parameters": {
        "url": "http://scraperr:8000/health"
      }
    },
    {
      "name": "Check Scrapper",
      "parameters": {
        "url": "http://scrapper:3000/health"
      }
    },
    {
      "name": "Check Miniflux",
      "parameters": {
        "url": "http://miniflux:8080/healthcheck"
      }
    }
  ]
}
```

### Retry Logic Template
```json
{
  "name": "Robust HTTP Request with Retry",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "{{ $json.target_url }}",
    "method": "GET",
    "options": {
      "timeout": 30000,
      "retry": {
        "enabled": true,
        "maxAttempts": 3,
        "waitBetween": 1000
      }
    }
  },
  "onError": "continueRegularOutput"
}
```

## PERFORMANCE OPTIMIZATION

### Batch Processing Template
```json
{
  "name": "Batch URL Processing",
  "type": "n8n-nodes-base.function",
  "parameters": {
    "functionCode": "// Process URLs in batches of 10\nconst batchSize = 10;\nconst urls = $input.all().map(item => item.json.url);\nconst batches = [];\n\nfor (let i = 0; i < urls.length; i += batchSize) {\n  batches.push(urls.slice(i, i + batchSize));\n}\n\nreturn batches.map((batch, index) => ({\n  json: {\n    batch_id: index,\n    urls: batch,\n    total_batches: batches.length\n  }\n}));"
  }
}
```

### Parallel Processing
```json
{
  "name": "Parallel Scraper Execution",
  "type": "n8n-nodes-base.splitInBatches",
  "parameters": {
    "batchSize": 5,
    "options": {
      "reset": false
    }
  }
}
```

## ENVIRONMENT VARIABLES REFERENCE

```bash
# Stack Configuration
N8N_DOMAIN=n8n.yourdomain.com
MINIFLUX_DOMAIN=miniflux.yourdomain.com
CRAWL4AI_DOMAIN=crawl4ai.yourdomain.com
SCRAPERR_DOMAIN=scraperr.yourdomain.com
SCRAPPER_DOMAIN=scrapper.yourdomain.com

# Database Credentials
N8N_DB_PASS=pass
MINIFLUX_PASS=miniflux
MINIFLUX_ADMIN_PASS=admin123

# API Tokens
CRAWL4AI_TOKEN=your-secret-token

# Network Configuration  
NPM_NETWORK=npm_network
```

## COMMON AUTOMATION PATTERNS

### Pattern 1: RSS → AI Analysis → Notification
```
RSS Feed → Content Extraction → AI Summary → Quality Filter → Notification
```

### Pattern 2: Scheduled Monitoring → Alert
```  
Schedule → URL Check → Content Compare → Threshold Check → Alert
```

### Pattern 3: Webhook → Multi-Service Scrape → Aggregate
```
Webhook → Service Router → [Crawl4AI + Scrapper + Scraperr] → Merge → Store
```

### Pattern 4: Data Pipeline → Processing → Export
```
Source → Extract → Transform → Load → Process → Export
```

## INTEGRATION EXAMPLES

### Discord Bot Integration
```json
{
  "name": "Discord Notification",
  "type": "n8n-nodes-base.discord",
  "parameters": {
    "resource": "message",
    "operation": "post",
    "channelId": "YOUR_CHANNEL_ID",
    "content": "🤖 **New Content Alert**\n\n**Title:** {{ $json.title }}\n**URL:** {{ $json.url }}\n**Summary:** {{ $json.ai_summary }}\n**Source:** {{ $json.source_service }}"
  }
}
```

### Slack Integration  
```json
{
  "name": "Slack Alert",
  "type": "n8n-nodes-base.slack",
  "parameters": {
    "resource": "message",
    "operation": "post",
    "channel": "#automation-alerts",
    "text": "New high-priority content detected",
    "attachments": [
      {
        "color": "good",
        "title": "{{ $json.title }}",
        "title_link": "{{ $json.url }}",
        "text": "{{ $json.summary }}",
        "fields": [
          {
            "title": "Source",
            "value": "{{ $json.source_service }}",
            "short": true
          },
          {
            "title": "Score", 
            "value": "{{ $json.relevance_score }}/100",
            "short": true
          }
        ]
      }
    ]
  }
}
```

This comprehensive guide provides everything needed for any LLM to generate sophisticated n8n automations perfectly tailored to your exact stack configuration!
