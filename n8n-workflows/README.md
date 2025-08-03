# N8N Automation Workflows

This directory contains four comprehensive N8N workflows that run daily to collect, process, and report on various data sources as part of the automation stack.

## Workflows Overview

### 1. Market Intelligence Workflow (`market-intelligence-workflow.json`)
- **Schedule**: Daily at 6:00 AM UTC
- **Purpose**: Collect and analyze market intelligence from RSS feeds
- **Features**:
  - Integrates with Miniflux for RSS feed collection
  - Uses Crawl4AI for intelligent content extraction
  - Stores data in PostgreSQL with Redis caching
  - Generates LaTeX reports
  - Includes error handling and rate limiting

### 2. Competitive Analysis Workflow (`competitive-analysis-workflow.json`)
- **Schedule**: Daily at 8:00 AM UTC
- **Purpose**: Monitor and analyze competitor websites and pricing
- **Features**:
  - Uses both Scraperr and Scrapper services for comprehensive data collection
  - Crawl4AI analysis for competitive intelligence
  - Tracks pricing, features, and market positioning
  - PostgreSQL storage with Redis caching
  - Automated competitive analysis reports

### 3. Industry News Workflow (`industry-news-workflow.json`)
- **Schedule**: Daily at 10:00 AM UTC
- **Purpose**: Aggregate and analyze industry news from multiple sources
- **Features**:
  - Advanced content deduplication logic
  - Automatic categorization and sentiment analysis
  - Trend identification and analysis
  - Multi-source RSS feed processing
  - Comprehensive news digest generation

### 4. Technical Analysis Workflow (`technical-analysis-workflow.json`)
- **Schedule**: Daily at 12:00 PM UTC
- **Purpose**: Analyze technical landscape and developer trends
- **Features**:
  - GitHub repository analysis and metrics
  - Technical documentation scraping
  - Developer blog content analysis
  - Framework and technology trend tracking
  - Technical innovation monitoring

## Prerequisites

### Environment Variables
Ensure the following environment variables are set in your `.env` file:

```bash
# Crawl4AI API Token
CRAWL4AI_TOKEN=your-secret-token

# Database credentials (automatically set in docker-compose)
N8N_DB_PASS=your-db-password
MINIFLUX_PASS=your-miniflux-password
MINIFLUX_ADMIN_PASS=admin123
```

### Database Setup
The workflows require specific database tables. These are automatically created by the initialization script:
- `postgres-init/init-n8n-workflows.sh`

### Service Dependencies
All workflows depend on the following services being running:
- PostgreSQL (database storage)
- Redis (caching)
- Miniflux (RSS feed management)
- Crawl4AI (AI-powered content analysis)
- Scraperr (web scraping with UI)
- Scrapper (headless browser scraping)

## Installation

1. **Start the automation stack**:
   ```bash
   make up
   ```

2. **Access N8N**:
   Open http://localhost:5678 in your browser

3. **Import workflows**:
   - In N8N, go to "Import from File"
   - Import each JSON file from this directory
   - Configure credentials as needed

4. **Configure credentials in N8N**:
   - **PostgreSQL**: Create credential named "PostgreSQL Main"
     - Host: `postgres`
     - Database: `n8n`
     - User: `n8n`
     - Password: Use `N8N_DB_PASS` environment variable
   - **Miniflux API**: Create credential for Miniflux access
     - URL: `http://miniflux:8080`
     - Username: `admin`
     - Password: Use `MINIFLUX_ADMIN_PASS` environment variable

## Workflow Features

### Error Handling
- Each workflow includes comprehensive error handling
- Failed requests are logged with detailed error messages
- Graceful degradation when services are unavailable
- Retry mechanisms for failed operations

### Rate Limiting
- Built-in delays between API calls to respect service limits
- Configurable timeouts for all HTTP requests
- Proper request spacing to avoid overwhelming services

### Data Storage
- All data is stored in PostgreSQL with proper indexing
- JSON data types for flexible analysis data storage
- Timestamp tracking for data freshness
- Relationships between related data points

### Caching Strategy
- Redis caching for processed data with 24-hour TTL
- Performance optimization for repeated queries
- Reduced load on analysis services

### Report Generation
- Professional LaTeX reports for each workflow
- Automated PDF generation
- Structured analysis sections
- Executive summaries with key insights

## Database Schema

### Tables Created
- `market_intelligence`: Market analysis data
- `competitive_analysis`: Competitor monitoring data
- `industry_news`: News aggregation and sentiment data
- `technical_analysis`: Technical landscape analysis
- `daily_automation_summary`: Combined view of all analyses

### Key Fields
Each table includes:
- Date-based partitioning for efficient queries
- JSON fields for flexible data storage
- Timestamp tracking for processing times
- Indexed fields for performance

## Monitoring and Maintenance

### Workflow Monitoring
- Check N8N execution history for workflow status
- Monitor database growth and performance
- Review Redis cache utilization
- Validate report generation success

### Data Retention
- Configure data retention policies as needed
- Monitor disk usage for PostgreSQL
- Implement backup strategies for critical data

### Performance Tuning
- Adjust rate limiting based on service capacity
- Optimize database queries for large datasets
- Configure Redis memory limits appropriately

## Troubleshooting

### Common Issues
1. **Service Unavailable**: Ensure all docker services are running
2. **API Token Issues**: Verify CRAWL4AI_TOKEN is set correctly
3. **Database Connection**: Check PostgreSQL credentials in N8N
4. **Rate Limiting**: Adjust delays if services return rate limit errors

### Logs and Debugging
- Check N8N execution logs for detailed error information
- Monitor docker logs for service-specific issues
- Use database queries to verify data is being stored correctly

## Customization

### Adding New Data Sources
1. Modify the "Define Sources" nodes in workflows
2. Add new RSS feeds to Miniflux
3. Update scraping targets in Scraperr/Scrapper configurations
4. Adjust analysis prompts for new content types

### Modifying Schedules
1. Edit the cron expressions in trigger nodes
2. Ensure workflows don't overlap and overwhelm services
3. Consider timezone implications for global operations

### Extending Analysis
1. Update Crawl4AI prompts for more specific insights
2. Add new categorization logic in code nodes
3. Create additional database fields for new metrics
4. Enhance LaTeX reports with new sections

## Support

For issues or questions:
1. Check N8N documentation for node-specific help
2. Review service logs for integration issues
3. Consult the automation stack documentation
4. Validate JSON workflow structure if making modifications