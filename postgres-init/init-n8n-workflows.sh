#!/bin/bash
# This script creates the required database tables for the N8N workflows
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Market Intelligence table
    CREATE TABLE IF NOT EXISTS market_intelligence (
        id SERIAL PRIMARY KEY,
        date DATE NOT NULL,
        source_feeds TEXT,
        article_count INTEGER,
        analysis_data JSONB,
        key_insights TEXT,
        processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_market_intelligence_date ON market_intelligence(date);
    CREATE INDEX IF NOT EXISTS idx_market_intelligence_processed_at ON market_intelligence(processed_at);

    -- Competitive Analysis table
    CREATE TABLE IF NOT EXISTS competitive_analysis (
        id SERIAL PRIMARY KEY,
        date DATE NOT NULL,
        competitors_analyzed INTEGER,
        analysis_data JSONB,
        scraped_content JSONB,
        key_findings TEXT,
        pricing_insights TEXT,
        feature_comparison TEXT,
        processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_competitive_analysis_date ON competitive_analysis(date);
    CREATE INDEX IF NOT EXISTS idx_competitive_analysis_processed_at ON competitive_analysis(processed_at);

    -- Industry News table
    CREATE TABLE IF NOT EXISTS industry_news (
        id SERIAL PRIMARY KEY,
        date DATE NOT NULL,
        total_articles INTEGER,
        duplicates_removed INTEGER,
        category_distribution JSONB,
        sentiment_analysis JSONB,
        trending_topics TEXT,
        overall_sentiment VARCHAR(20),
        key_insights TEXT,
        source_feeds TEXT,
        processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_industry_news_date ON industry_news(date);
    CREATE INDEX IF NOT EXISTS idx_industry_news_processed_at ON industry_news(processed_at);
    CREATE INDEX IF NOT EXISTS idx_industry_news_sentiment ON industry_news(overall_sentiment);

    -- Technical Analysis table
    CREATE TABLE IF NOT EXISTS technical_analysis (
        id SERIAL PRIMARY KEY,
        date DATE NOT NULL,
        repositories_analyzed INTEGER,
        total_github_stars INTEGER,
        language_distribution JSONB,
        technical_trends TEXT,
        framework_analysis TEXT,
        developer_activity TEXT,
        innovation_areas TEXT,
        analysis_data JSONB,
        scraped_sources TEXT,
        processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_technical_analysis_date ON technical_analysis(date);
    CREATE INDEX IF NOT EXISTS idx_technical_analysis_processed_at ON technical_analysis(processed_at);

    -- Grant permissions to n8n user
    GRANT ALL PRIVILEGES ON TABLE market_intelligence TO n8n;
    GRANT ALL PRIVILEGES ON TABLE competitive_analysis TO n8n;
    GRANT ALL PRIVILEGES ON TABLE industry_news TO n8n;
    GRANT ALL PRIVILEGES ON TABLE technical_analysis TO n8n;

    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO n8n;

    -- Create a view for daily summary
    CREATE OR REPLACE VIEW daily_automation_summary AS
    SELECT 
        COALESCE(mi.date, ca.date, inn.date, ta.date) as analysis_date,
        mi.article_count as market_articles,
        mi.key_insights as market_insights,
        ca.competitors_analyzed,
        ca.key_findings as competitive_findings,
        inn.total_articles as news_articles,
        inn.overall_sentiment as news_sentiment,
        ta.repositories_analyzed as tech_repos,
        ta.technical_trends
    FROM market_intelligence mi
    FULL OUTER JOIN competitive_analysis ca ON mi.date = ca.date
    FULL OUTER JOIN industry_news inn ON COALESCE(mi.date, ca.date) = inn.date
    FULL OUTER JOIN technical_analysis ta ON COALESCE(mi.date, ca.date, inn.date) = ta.date
    ORDER BY analysis_date DESC;

    GRANT SELECT ON daily_automation_summary TO n8n;
EOSQL