#!/bin/bash
# This script is executed on PostgreSQL container startup if the database is new.
# It creates the dedicated user and database for the Miniflux service.
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER miniflux WITH PASSWORD '${MINIFLUX_PASS:-miniflux}';
    CREATE DATABASE miniflux OWNER miniflux;
EOSQL
