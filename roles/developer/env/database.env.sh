# ==============================================================================
# Database Environment Variables
#
# Configuration for local development databases including PostgreSQL, MySQL,
# Redis, MongoDB, and SQLite. These settings optimize local database connections.
#
# USAGE:
#   These variables are set when the developer role is active.
#   Customize connection settings for your local development databases.
#
# SECURITY:
#   - Never commit database passwords to version control
#   - Use environment variables or secrets management for credentials
#   - These are local development defaults only
# ==============================================================================

# --- PostgreSQL Configuration ------------------------------------------------

# Default connection settings for local PostgreSQL
export PGHOST="${PGHOST:-localhost}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}"

# Default database (commonly used for development)
export PGDATABASE="${PGDATABASE:-postgres}"

# SSL mode for local development
# Options: disable, allow, prefer, require, verify-ca, verify-full
export PGSSLMODE="${PGSSLMODE:-prefer}"

# Connection timeout (seconds)
export PGCONNECT_TIMEOUT="${PGCONNECT_TIMEOUT:-10}"

# Application name (shows in pg_stat_activity)
export PGAPPNAME="${PGAPPNAME:-local-dev}"

# History file for psql
export PSQL_HISTORY="${PSQL_HISTORY:-$HOME/.psql_history}"

# psql pager settings
export PSQL_PAGER="${PSQL_PAGER:-less -S}"

# --- MySQL/MariaDB Configuration ---------------------------------------------

# Default connection settings for local MySQL
export MYSQL_HOST="${MYSQL_HOST:-localhost}"
export MYSQL_TCP_PORT="${MYSQL_TCP_PORT:-3306}"

# MySQL history file
export MYSQL_HISTFILE="${MYSQL_HISTFILE:-$HOME/.mysql_history}"

# MySQL prompt customization
export MYSQL_PS1="${MYSQL_PS1:-[\u@\h:\d]> }"

# Default character set
export MYSQL_DEFAULT_CHARSET="${MYSQL_DEFAULT_CHARSET:-utf8mb4}"

# --- Redis Configuration -----------------------------------------------------

# Default Redis connection
export REDIS_HOST="${REDIS_HOST:-localhost}"
export REDIS_PORT="${REDIS_PORT:-6379}"

# Redis URL format (commonly used by libraries)
export REDIS_URL="${REDIS_URL:-redis://localhost:6379/0}"

# Redis CLI history
export REDISCLI_HISTFILE="${REDISCLI_HISTFILE:-$HOME/.rediscli_history}"

# Redis authentication (uncomment if password required)
# export REDIS_PASSWORD="${REDIS_PASSWORD:-}"

# --- MongoDB Configuration ---------------------------------------------------

# Default MongoDB connection
export MONGO_HOST="${MONGO_HOST:-localhost}"
export MONGO_PORT="${MONGO_PORT:-27017}"

# MongoDB connection URL
export MONGODB_URI="${MONGODB_URI:-mongodb://localhost:27017}"

# MongoDB shell history
export MONGODB_HISTFILE="${MONGODB_HISTFILE:-$HOME/.dbshell}"

# --- SQLite Configuration ----------------------------------------------------

# SQLite history file
export SQLITE_HISTFILE="${SQLITE_HISTFILE:-$HOME/.sqlite_history}"

# SQLite default options
# Enable foreign keys by default
export SQLITE_DEFAULT_FOREIGN_KEYS="${SQLITE_DEFAULT_FOREIGN_KEYS:-1}"

# --- Generic Database URL Templates ------------------------------------------

# Common DATABASE_URL format templates (uncomment and customize)
# PostgreSQL: export DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
# MySQL:      export DATABASE_URL="mysql://user:password@localhost:3306/dbname"
# SQLite:     export DATABASE_URL="sqlite:///path/to/database.db"

# Connection pool settings (used by many ORMs)
export DB_POOL_SIZE="${DB_POOL_SIZE:-5}"
export DB_POOL_TIMEOUT="${DB_POOL_TIMEOUT:-30}"
export DB_POOL_RECYCLE="${DB_POOL_RECYCLE:-3600}"

# --- ORMs and Query Builders -------------------------------------------------

# Prisma
export PRISMA_HIDE_UPDATE_MESSAGE="${PRISMA_HIDE_UPDATE_MESSAGE:-1}"

# TypeORM logging
export TYPEORM_LOGGING="${TYPEORM_LOGGING:-false}"

# Sequelize
export SEQUELIZE_LOGGING="${SEQUELIZE_LOGGING:-false}"

# --- Elasticsearch Configuration ---------------------------------------------

# Default Elasticsearch connection
export ELASTICSEARCH_HOST="${ELASTICSEARCH_HOST:-localhost}"
export ELASTICSEARCH_PORT="${ELASTICSEARCH_PORT:-9200}"
export ELASTICSEARCH_URL="${ELASTICSEARCH_URL:-http://localhost:9200}"

# --- Memcached Configuration -------------------------------------------------

# Default Memcached connection
export MEMCACHED_HOST="${MEMCACHED_HOST:-localhost}"
export MEMCACHED_PORT="${MEMCACHED_PORT:-11211}"

# --- CockroachDB Configuration -----------------------------------------------

# CockroachDB uses PostgreSQL wire protocol
export COCKROACH_HOST="${COCKROACH_HOST:-localhost}"
export COCKROACH_PORT="${COCKROACH_PORT:-26257}"

# --- DynamoDB Local ----------------------------------------------------------

# AWS DynamoDB Local (for local development)
export DYNAMODB_LOCAL_ENDPOINT="${DYNAMODB_LOCAL_ENDPOINT:-http://localhost:8000}"

# --- Database GUI Tools ------------------------------------------------------

# TablePlus connection folder
export TABLEPLUS_CONNECTIONS="${TABLEPLUS_CONNECTIONS:-$HOME/.tableplus}"

# DBeaver workspace
export DBEAVER_WORKSPACE="${DBEAVER_WORKSPACE:-$HOME/.dbeaver}"

# --- Database Migration Tools ------------------------------------------------

# Flyway locations
export FLYWAY_LOCATIONS="${FLYWAY_LOCATIONS:-filesystem:./migrations}"

# Liquibase changelog
export LIQUIBASE_CHANGELOG="${LIQUIBASE_CHANGELOG:-db/changelog.xml}"

# Alembic (Python SQLAlchemy migrations)
export ALEMBIC_CONFIG="${ALEMBIC_CONFIG:-alembic.ini}"

# --- Helper Functions --------------------------------------------------------

# Quick connect to local PostgreSQL
pglocal() {
    psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "${1:-$PGDATABASE}"
}

# Quick connect to local MySQL
mylocal() {
    mysql -h "$MYSQL_HOST" -P "$MYSQL_TCP_PORT" "${1:-mysql}"
}

# Quick connect to local Redis
redislocal() {
    redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT"
}

# Quick connect to local MongoDB
mongolocal() {
    mongosh "$MONGODB_URI/${1:-test}"
}

# Show database connection info
dbinfo() {
    echo "=== Database Connection Info ==="
    echo ""
    echo "PostgreSQL:"
    echo "  Host: $PGHOST:$PGPORT"
    echo "  User: $PGUSER"
    echo "  Database: $PGDATABASE"
    echo ""
    echo "MySQL:"
    echo "  Host: $MYSQL_HOST:$MYSQL_TCP_PORT"
    echo ""
    echo "Redis:"
    echo "  URL: $REDIS_URL"
    echo ""
    echo "MongoDB:"
    echo "  URI: $MONGODB_URI"
}
